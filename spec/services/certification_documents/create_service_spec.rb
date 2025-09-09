# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificationDocuments::CreateService, type: :service do
  with_blockchain_mocks
  let(:producer_profile) { create(:producer_profile) }
  let(:vet_profile) { create(:vet_profile) }
  let(:locality) { create(:locality) }
  let(:certification_request) do
    create(:certification_request,
           producer_profile: producer_profile,
           vet_profile: vet_profile,
           locality: locality)
  end
  let(:certified_lot) { create(:certified_lot, certification_request: certification_request) }
  let(:cattle_certification) { create(:cattle_certification, :with_photo, certified_lot: certified_lot) }

  let(:service) { described_class.new(cattle_certification: cattle_certification) }

  let(:sample_pdf_path) { Rails.root.join('spec/fixtures/files/sample_certificate.pdf') }
  let(:sample_pdf_content) { File.read(sample_pdf_path) }

  before do
    # Create blockchain wallets for producer and vet
    create(:blockchain_wallet, producer_profile: producer_profile)
    create(:blockchain_wallet, vet_profile: vet_profile)

    # Mock PDF generator to return real PDF content
    allow(Utils::CattleCertificationPdfGenerator).to receive(:call).and_return(sample_pdf_content)
  end

  around do |example|
    I18n.with_locale(:es) do
      example.run
    end
  end

  describe '#call!' do
    context 'when all services work correctly' do
      before do
        # Use centralized blockchain mocks
        mock_signature_service
      end

      it 'creates a certification document successfully' do
        expect { service.call! }.to change(CertificationDocument, :count).by(1)
      end

      it 'creates a blockchain transaction' do
        expect { service.call! }.to change(BlockchainTransaction, :count).by(1)
      end

      it 'attaches the PDF file' do
        cert_doc = service.call!
        expect(cert_doc.pdf_file).to be_attached
      end

      it 'generates correct filename' do
        cert_doc = service.call!
        expect(cert_doc.filename).to match(/cert_.*\.pdf/)
      end

      it 'calculates PDF hash correctly' do
        cert_doc = service.call!
        expect(cert_doc.pdf_hash).to start_with('0x')
        expect(cert_doc.pdf_hash.length).to eq(66) # 0x + 64 hex characters
      end

      it 'updates blockchain transaction with result' do
        cert_doc = service.call!
        blockchain_tx = cert_doc.blockchain_transaction

        expect(blockchain_tx.transaction_hash).to match(/0x[a-f0-9]{64}/)
        expect(blockchain_tx.status).to eq('confirmed')
      end

      it 'marks certification request as executed' do
        service.call!

        certification_request.reload
        expect(certification_request.status).to eq('executed')
      end
    end

    context 'when certification document already exists' do
      before do
        create(:blockchain_transaction, transaction_hash: 'existing_tx', status: 'confirmed', network: 'test',
                                        contract_address: ENV.fetch('CERTIFICATION_CONTRACT_ADDRESS'))
        existing_blockchain_tx = BlockchainTransaction.last
        create(:certification_document,
               cattle_certification: cattle_certification,
               pdf_hash: '0xexisting_hash',
               filename: 'existing.pdf',
               blockchain_transaction: existing_blockchain_tx)
      end

      it 'raises StandardError' do
        expect { service.call! }
          .to raise_error(StandardError)
      end
    end

    context 'when PDF generation fails' do
      before do
        allow(Utils::CattleCertificationPdfGenerator).to receive(:call)
          .and_raise(StandardError.new('PDF generation failed'))
      end

      it 'raises StandardError' do
        expect { service.call! }
          .to raise_error(StandardError)
      end
    end

    context 'when blockchain certification fails' do
      before do
        mock_signature_service

        # Override the blockchain service to raise an error
        mock_blockchain_service = instance_double(Blockchain::CertificationService)
        allow(Blockchain::CertificationService).to receive(:new).and_return(mock_blockchain_service)
        allow(mock_blockchain_service).to receive(:certify_document)
          .and_raise(StandardError.new('Network error'))
      end

      it 'does not mark certification request as executed' do
        expect { service.call! }.to raise_error(StandardError)

        # La solicitud de certificación no debe cambiar de estado
        certification_request.reload
        expect(certification_request.status).not_to eq('executed')
      end
    end
  end

  describe 'filename generation' do
    it 'generates filename with CUIG, date and producer' do
      allow(cattle_certification).to receive(:cuig_code).and_return('CUIG123456789')
      allow(cattle_certification).to receive(:data_taken_at).and_return(Date.parse('2024-03-08'))
      allow(producer_profile).to receive(:cuig_number).and_return('PROD987654321')

      filename = service.send(:generate_filename)
      expect(filename).to include('cert_CUIG123456789_20240308_PROD987654321.pdf')
    end

    it 'handles missing CUIG codes gracefully' do
      allow(cattle_certification).to receive(:cuig_code).and_return(nil)
      allow(producer_profile).to receive(:cuig_number).and_return(nil)

      filename = service.send(:generate_filename)
      expect(filename).to include('NOCUIG')
      expect(filename).to include('NOPROD')
    end
  end
end
