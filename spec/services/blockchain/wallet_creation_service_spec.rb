# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blockchain::WalletCreationService, type: :service do
  describe '#call!' do
    it 'creates a new blockchain wallet with valid Ethereum address' do
      wallet = described_class.new.call!

      expect(wallet).to be_persisted
    end

    it 'creates unique wallets on multiple calls' do
      wallet1 = described_class.new.call!
      wallet2 = described_class.new.call!

      expect(wallet1.address).not_to eq(wallet2.address)
      expect(wallet1.private_key).not_to eq(wallet2.private_key)
    end
  end
end
