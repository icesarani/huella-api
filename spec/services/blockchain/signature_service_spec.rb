# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blockchain::SignatureService, type: :service do
  with_blockchain_mocks

  let(:producer_wallet) { create(:blockchain_wallet) }
  let(:vet_wallet) { create(:blockchain_wallet) }
  let(:pdf_hash) { "0x#{SecureRandom.hex(32)}" }

  let(:service) do
    described_class.new(
      pdf_hash: pdf_hash,
      owner_wallet: producer_wallet,
      vet_wallet: vet_wallet
    )
  end

  describe '#call!' do
    it 'generates signatures for both wallets' do
      result = service.call!

      expect(result).to be_a(Hash)
      expect(result[:owner_signature]).to match(/[a-f0-9]{130}/)
      expect(result[:vet_signature]).to match(/[a-f0-9]{130}/)
      expect(result[:message_hash]).to be_present
    end

    it 'generates different signatures for each wallet' do
      result = service.call!

      expect(result[:owner_signature]).not_to eq(result[:vet_signature])
    end

    it 'includes the message hash' do
      result = service.call!

      expect(result[:message_hash]).to be_present
    end
  end

  describe 'error handling' do
    context 'with invalid wallet data' do
      let(:invalid_wallet) { double('wallet', address: 'invalid', private_key: nil) }

      it 'handles signature errors gracefully' do
        service = described_class.new(
          pdf_hash: pdf_hash,
          owner_wallet: invalid_wallet,
          vet_wallet: vet_wallet
        )

        expect { service.call! }.to raise_error(StandardError)
      end
    end
  end

  describe 'message generation' do
    it 'creates consistent message for signing' do
      # Call twice with same parameters
      result1 = service.call!

      service2 = described_class.new(
        pdf_hash: pdf_hash,
        owner_wallet: producer_wallet,
        vet_wallet: vet_wallet
      )
      result2 = service2.call!

      # Message hash should be the same for same inputs
      expect(result1[:message_hash]).to eq(result2[:message_hash])
    end
  end

  describe 'signature verification' do
    it 'can verify generated signatures' do
      result = service.call!

      # Test owner signature verification
      owner_valid = described_class.verify_signature(
        pdf_hash: pdf_hash,
        owner_address: producer_wallet.address,
        vet_address: vet_wallet.address,
        signature: result[:owner_signature],
        expected_signer: producer_wallet.address
      )

      expect(owner_valid).to be true
    end
  end
end
