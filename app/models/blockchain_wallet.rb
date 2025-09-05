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

class BlockchainWallet < ApplicationRecord
  has_one :producer_profile, inverse_of: :blockchain_wallet
  has_one :vet_profile, inverse_of: :blockchain_wallet

  encrypts :mnemonic_phrase
  encrypts :private_key

  validates :address, presence: true, uniqueness: true

  def profile
    producer_profile || vet_profile
  end
end
