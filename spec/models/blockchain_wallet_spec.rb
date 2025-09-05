# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_wallets
#
#  id              :bigint           not null, primary key
#  address         :string
#  mnemonic_phrase :string
#  private_key     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_blockchain_wallets_on_address  (address) UNIQUE
#

require 'rails_helper'

RSpec.describe BlockchainWallet, type: :model do
  subject(:blockchain_wallet) { build(:blockchain_wallet) }

  describe 'associations' do
    it 'has one producer profile' do
      expect(subject).to have_one(:producer_profile)
    end

    it 'has one vet profile' do
      expect(subject).to have_one(:vet_profile)
    end
  end

  describe 'validations' do
    it 'validates presence of address' do
      expect(subject).to validate_presence_of(:address)
    end

    it 'validates uniqueness of address' do
      expect(subject).to validate_uniqueness_of(:address)
    end
  end

  describe 'encryption' do
    it 'encrypts mnemonic phrase' do
      wallet = create(:blockchain_wallet, mnemonic_phrase: 'secret phrase')

      expect(wallet.mnemonic_phrase).to eq('secret phrase')
    end

    it 'encrypts private key' do
      private_key = '0x1234567890abcdef'
      wallet = create(:blockchain_wallet, private_key: private_key)

      expect(wallet.private_key).to eq(private_key)
    end

    it 'stores encrypted data in database' do
      wallet = create(:blockchain_wallet, mnemonic_phrase: 'secret phrase')
      raw_value = wallet.class.connection.select_value(
        "SELECT mnemonic_phrase FROM blockchain_wallets WHERE id = #{wallet.id}"
      )

      expect(raw_value).not_to eq('secret phrase')
    end
  end

  describe '#profile' do
    context 'when wallet has no profile' do
      it 'returns nil' do
        wallet = create(:blockchain_wallet)

        expect(wallet.profile).to be_nil
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(blockchain_wallet).to be_valid
    end

    it 'generates unique addresses' do
      wallet1 = create(:blockchain_wallet)
      wallet2 = create(:blockchain_wallet)

      expect(wallet1.address).not_to eq(wallet2.address)
    end
  end
end
