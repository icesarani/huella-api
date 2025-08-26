# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_wallets
#
#  id              :integer          not null, primary key
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

FactoryBot.define do
  factory :blockchain_wallet do
    sequence(:address) { |n| "0x#{n.to_s.rjust(40, '0')}" }
    mnemonic_phrase { 'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12' }
    private_key { "0x#{SecureRandom.hex(32)}" }
  end
end
