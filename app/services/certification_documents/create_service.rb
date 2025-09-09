# frozen_string_literal: true

module CertificationDocuments
  class CreateService < ApplicationService # rubocop:disable Metrics/ClassLength
    def initialize(cattle_certification:)
      @cattle_certification = cattle_certification
      @network = ENV.fetch('BLOCKCHAIN_NETWORK', 'amoy')
      super()
    end

    def call! # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      ActiveRecord::Base.transaction do
        # 1. Verificar que no existe ya un documento
        verify_no_existing_document!

        # 2. Generar PDF
        pdf_content = generate_pdf

        # 3. Calcular hash del PDF
        pdf_hash = calculate_pdf_hash(pdf_content)

        # 4. Generar nombre único del archivo
        filename = generate_filename

        # 5. Crear transacción blockchain inicial (pending)
        blockchain_tx = create_blockchain_transaction(pdf_hash)

        # 6. Crear documento de certificación
        cert_doc = create_certification_document(pdf_hash, filename, blockchain_tx)

        # 7. Adjuntar PDF usando Active Storage
        attach_pdf_file(cert_doc, pdf_content, filename)

        # Reload para asegurar que el archivo esté adjunto antes de validaciones
        cert_doc.reload

        # Ahora validar que todo esté correcto
        cert_doc.validate!
        raise StandardError, cert_doc.errors.full_messages.join(', ') if cert_doc.errors.any?

        # 8. Generar firmas digitales
        signatures = generate_signatures(pdf_hash)

        # 9. Enviar a blockchain
        blockchain_result = send_to_blockchain(pdf_hash, signatures)

        # 10. Actualizar transacción con resultado
        update_blockchain_transaction(blockchain_tx, blockchain_result)

        # 11. Marcar la solicitud de certificación como ejecutada/terminada
        mark_certification_request_as_executed

        cert_doc.reload
      end
    end

    private

    attr_reader :cattle_certification, :network

    def verify_no_existing_document!
      existing = CertificationDocument.find_by(cattle_certification: @cattle_certification)
      return unless existing

      raise StandardError, I18n.t('errors.certification_document.already_exists', id: @cattle_certification.id)
    end

    def generate_pdf
      Utils::CattleCertificationPdfGenerator.call(cattle_certification: @cattle_certification)
      # Dejar que el error se propague naturalmente
    end

    def calculate_pdf_hash(pdf_content)
      "0x#{CertificationDocument.calculate_pdf_hash(pdf_content)}"
    end

    def generate_filename
      date = @cattle_certification.data_taken_at&.strftime('%Y%m%d') || Date.current.strftime('%Y%m%d')
      cuig = sanitize_filename_part(@cattle_certification.cuig_code || 'NOCUIG')
      producer_cuig = sanitize_filename_part(
        @cattle_certification.certified_lot.certification_request.producer_profile.cuig_number || 'NOPROD'
      )

      "cert_#{cuig}_#{date}_#{producer_cuig}.pdf"
    end

    def create_blockchain_transaction(_pdf_hash)
      BlockchainTransaction.create!(
        transaction_hash: generate_temp_hash, # Temporal, se actualizará después
        status: 'pending',
        network: @network,
        contract_address: ENV.fetch('CERTIFICATION_CONTRACT_ADDRESS')
      )
    end

    def create_certification_document(pdf_hash, filename, blockchain_tx)
      # Crear sin validar primero, validaremos después de adjuntar el archivo
      cert_doc = CertificationDocument.new(
        cattle_certification: @cattle_certification,
        pdf_hash: pdf_hash,
        filename: filename,
        blockchain_transaction: blockchain_tx
      )

      # Guardar sin validaciones primero
      cert_doc.save!(validate: false)
      cert_doc
    end

    def attach_pdf_file(cert_doc, pdf_content, filename)
      cert_doc.pdf_file.attach(
        io: StringIO.new(pdf_content),
        filename: filename,
        content_type: 'application/pdf'
      )
    end

    def generate_signatures(pdf_hash)
      # Obtener wallets del productor y veterinario
      producer_wallet = @cattle_certification.certified_lot.certification_request.producer_profile.blockchain_wallet
      vet_wallet = @cattle_certification.certified_lot.certification_request.vet_profile.blockchain_wallet

      raise StandardError, I18n.t('errors.blockchain.missing_blockchain_wallets') unless producer_wallet && vet_wallet

      # Generar firmas
      Blockchain::SignatureService.new(
        pdf_hash: pdf_hash,
        owner_wallet: producer_wallet,
        vet_wallet: vet_wallet
      ).call!
      # Dejar que el error se propague naturalmente
    end

    def send_to_blockchain(pdf_hash, signatures)
      producer_address = @cattle_certification.certified_lot.certification_request.producer_profile.blockchain_wallet
                                              .address
      vet_address = @cattle_certification.certified_lot.certification_request.vet_profile.blockchain_wallet.address

      certification_service = Blockchain::CertificationService.new

      # Obtener el CUIG del animal para usar como ID único
      animal_id = @cattle_certification.cuig_code

      # Hacer la llamada real a blockchain - si falla, se propagará el error y se hará rollback
      certification_service.certify_document(
        pdf_hash: pdf_hash,
        animal_id: animal_id, # CUIG como identificador único del animal
        owner_address: producer_address,
        vet_address: vet_address,
        owner_signature: signatures[:owner_signature],
        vet_signature: signatures[:vet_signature]
      )
    end

    def update_blockchain_transaction(blockchain_tx, result)
      if result[:success]
        blockchain_tx.update!(
          transaction_hash: result[:transaction_hash],
          block_number: result[:block_number],
          gas_used: result[:gas_used],
          status: result[:status],
          raw_response: result
        )
      else
        blockchain_tx.update!(
          status: 'failed',
          error_message: result[:error],
          raw_response: result
        )
      end
    end

    def sanitize_filename_part(str)
      str.to_s.gsub(/[^a-zA-Z0-9]/, '').upcase
    end

    def generate_temp_hash
      "temp_#{SecureRandom.hex(20)}"
    end

    def mark_certification_request_as_executed
      certification_request = @cattle_certification.certified_lot.certification_request
      certification_request.update!(status: 'executed')
    end
  end
end
