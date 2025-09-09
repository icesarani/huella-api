# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blockchain::CertificationService, type: :service do
  with_blockchain_mocks

  let(:service) { described_class.new }
  let(:pdf_hash) { "0x#{SecureRandom.hex(32)}" }
  let(:animal_id) { 'CUIG123456' }
  let(:owner_address) { "0x#{SecureRandom.hex(20)}" }
  let(:vet_address) { "0x#{SecureRandom.hex(20)}" }
  let(:owner_signature) { SecureRandom.hex(65) }
  let(:vet_signature) { SecureRandom.hex(65) }

  describe '#certify_document' do
    context 'with valid parameters' do
      it 'successfully certifies document on blockchain' do
        result = service.certify_document(
          pdf_hash: pdf_hash,
          animal_id: animal_id,
          owner_address: owner_address,
          vet_address: vet_address,
          owner_signature: owner_signature,
          vet_signature: vet_signature
        )

        expect(result[:success]).to be true
        expect(result[:transaction_hash]).to match(/0x[a-f0-9]{64}/)
        # Array response doesn't include block_number and gas_used
        expect(result[:status]).to eq('confirmed')
        expect(result[:network]).to eq('amoy')
      end

      it 'includes contract address in response' do
        result = service.certify_document(
          pdf_hash: pdf_hash,
          animal_id: animal_id,
          owner_address: owner_address,
          vet_address: vet_address,
          owner_signature: owner_signature,
          vet_signature: vet_signature
        )

        expect(result[:contract_address]).to eq(ENV.fetch('CERTIFICATION_CONTRACT_ADDRESS'))
      end
    end

    context 'with invalid addresses' do
      it 'raises ArgumentError for invalid owner address' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            animal_id: animal_id,
            owner_address: 'invalid_address',
            vet_address: vet_address,
            owner_signature: owner_signature,
            vet_signature: vet_signature
          )
        end.to raise_error(ArgumentError, /Dirección de Ethereum inválida/)
      end

      it 'raises ArgumentError for invalid vet address' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            animal_id: animal_id,
            owner_address: owner_address,
            vet_address: 'invalid_address',
            owner_signature: owner_signature,
            vet_signature: vet_signature
          )
        end.to raise_error(ArgumentError, /Dirección de Ethereum inválida/)
      end
    end

    context 'with invalid signatures' do
      it 'raises ArgumentError for invalid owner signature' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            animal_id: animal_id,
            owner_address: owner_address,
            vet_address: vet_address,
            owner_signature: 'invalid_signature',
            vet_signature: vet_signature
          )
        end.to raise_error(ArgumentError, /Formato de firma inválido/)
      end

      it 'raises ArgumentError for invalid vet signature' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            animal_id: animal_id,
            owner_address: owner_address,
            vet_address: vet_address,
            owner_signature: owner_signature,
            vet_signature: 'invalid_signature'
          )
        end.to raise_error(ArgumentError, /Formato de firma inválido/)
      end
    end

    context 'when document is already certified' do
      before do
        # Mock that document is already certified
        allow(service).to receive(:document_certified?).with(pdf_hash).and_return(true)
      end

      it 'raises StandardError' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            animal_id: animal_id,
            owner_address: owner_address,
            vet_address: vet_address,
            owner_signature: owner_signature,
            vet_signature: vet_signature
          )
        end.to raise_error(StandardError, /ya está certificado/)
      end
    end

    context 'when blockchain call fails' do
      before do
        # Override mock to simulate failure
        allow(@mock_client).to receive(:transact_and_wait).and_raise(StandardError.new('Network timeout'))
      end

      it 'raises StandardError' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            animal_id: animal_id,
            owner_address: owner_address,
            vet_address: vet_address,
            owner_signature: owner_signature,
            vet_signature: vet_signature
          )
        end.to raise_error(StandardError)
      end
    end
  end

  describe '#verify_certification' do
    context 'when document is certified' do
      let(:certified_hash) { '0x123' }

      it 'returns certification information' do
        result = service.verify_certification(certified_hash)

        expect(result).to be_a(Hash)
        expect(result[:owner]).to eq('0x742d35Cc6634C0532925a3b8D05B6EC21D9e4C70')
        expect(result[:veterinarian]).to eq('0x8ba1f109551bD432803012645Hac136c59D8e8d9')
        expect(result[:registrar]).to eq('0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe')
        expect(result[:timestamp]).to be > 0
        expect(result[:certified_at]).to be_a(Time)
      end
    end

    context 'when document is not certified' do
      let(:uncertified_hash) { '0x999' }

      it 'returns nil' do
        result = service.verify_certification(uncertified_hash)
        expect(result).to be_nil
      end
    end

    context 'when blockchain call fails' do
      before do
        # Override mock to simulate failure
        allow(@mock_client).to receive(:call).and_raise(StandardError.new('RPC error'))
      end

      it 'raises StandardError' do
        expect do
          service.verify_certification(pdf_hash)
        end.to raise_error(StandardError)
      end
    end
  end

  describe '#document_certified?' do
    it 'returns true when document is certified' do
      result = service.document_certified?('0x123')
      expect(result).to be true
    end

    it 'returns false when document is not certified' do
      result = service.document_certified?('0x999')
      expect(result).to be false
    end
  end

  describe '#call!' do
    it 'raises NotImplementedError' do
      expect { service.call! }.to raise_error(NotImplementedError)
    end
  end
end
