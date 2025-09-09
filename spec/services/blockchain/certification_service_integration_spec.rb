# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blockchain::CertificationService, type: :service do
  describe 'Integration with real blockchain', if: ENV['BLOCKCHAIN_INTEGRATION'] == 'true' do
    let(:service) { described_class.new }
    let(:pdf_hash) { "0x#{SecureRandom.hex(32)}" }
    let(:owner_address) { "0x#{SecureRandom.hex(20)}" }
    let(:vet_address) { "0x#{SecureRandom.hex(20)}" }
    let(:owner_signature) { "0x#{SecureRandom.hex(65)}" }
    let(:vet_signature) { "0x#{SecureRandom.hex(65)}" }

    before(:all) do
      # Check that required environment variables are present
      required_vars = %w[
        CERTIFICATION_CONTRACT_ADDRESS
        COMPANY_WALLET_PRIVATE_KEY
        AMOY_RPC_URL
        BLOCKCHAIN_NETWORK
      ]

      missing_vars = required_vars.reject { |var| ENV[var] }

      if missing_vars.any?
        skip "Missing environment variables: #{missing_vars.join(', ')}. " \
             'Set these variables to run blockchain integration tests.'
      end
    end

    it 'connects to blockchain network successfully' do
      expect { service.send(:create_client) }.not_to raise_error
    end

    it 'loads contract ABI correctly' do
      expect { service.send(:load_contract) }.not_to raise_error
    end

    context 'when querying blockchain state' do
      it 'can check if a document is certified' do
        # Use a hash that definitely doesn't exist
        fake_hash = "0x#{'0' * 64}"

        expect do
          result = service.document_certified?(fake_hash)
          expect(result).to be false
        end.not_to raise_error
      end

      it 'can verify certification status' do
        # Use a hash that definitely doesn't exist
        fake_hash = "0x#{'0' * 64}"

        expect do
          result = service.verify_certification(fake_hash)
          expect(result).to be_nil
        end.not_to raise_error
      end
    end

    context 'when certifying document (requires tokens)' do
      # This test actually spends blockchain tokens - only run manually
      it 'certifies document on blockchain', if: ENV['RUN_SPEND_TOKENS'] == 'true' do
        result = service.certify_document(
          pdf_hash: pdf_hash,
          owner_address: owner_address,
          vet_address: vet_address,
          owner_signature: owner_signature,
          vet_signature: vet_signature
        )

        expect(result[:success]).to be true
        expect(result[:transaction_hash]).to be_present
        expect(result[:block_number]).to be > 0
        expect(result[:gas_used]).to be > 0
        expect(result[:status]).to eq('confirmed')
      end
    end

    context 'error handling' do
      it 'raises NetworkError for invalid RPC URL' do
        # Temporarily override RPC URL
        allow(ENV).to receive(:fetch).with('AMOY_RPC_URL', anything).and_return('http://invalid-url')

        expect do
          described_class.new
        end.to raise_error(Blockchain::CertificationService::NetworkError)
      end

      it 'validates addresses properly' do
        expect do
          service.certify_document(
            pdf_hash: pdf_hash,
            owner_address: 'invalid_address',
            vet_address: vet_address,
            owner_signature: owner_signature,
            vet_signature: vet_signature
          )
        end.to raise_error(ArgumentError, /Invalid Ethereum address/)
      end
    end
  end
end
