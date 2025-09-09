# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_transactions
#
#  id               :bigint           not null, primary key
#  block_number     :bigint
#  contract_address :string           not null
#  error_message    :text
#  gas_used         :bigint
#  network          :string           not null
#  raw_response     :json
#  status           :string           default("pending"), not null
#  transaction_hash :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_blockchain_transactions_on_network_and_contract_address  (network,contract_address)
#  index_blockchain_transactions_on_status                        (status)
#  index_blockchain_transactions_on_transaction_hash              (transaction_hash) UNIQUE
#
FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :blockchain_transaction do # rubocop:disable Metrics/BlockLength
    transaction_hash { "0x#{SecureRandom.hex(32)}" }
    status { 'pending' }
    network { 'amoy' }
    contract_address { "0x#{SecureRandom.hex(20)}" }
    block_number { nil }
    gas_used { nil }
    error_message { nil }
    raw_response { nil }

    trait :confirmed do
      status { 'confirmed' }
      block_number { rand(1_000_000..9_999_999) }
      gas_used { rand(21_000..100_000) }
      raw_response do
        {
          success: true,
          transaction_hash: transaction_hash,
          block_number: block_number,
          gas_used: gas_used,
          status: 'confirmed'
        }
      end
    end

    trait :failed do
      status { 'failed' }
      error_message { 'Transaction failed due to insufficient gas' }
      raw_response do
        {
          success: false,
          error: error_message,
          status: 'failed'
        }
      end
    end

    trait :polygon_mainnet do
      network { 'polygon' }
    end

    trait :ethereum_mainnet do
      network { 'ethereum' }
    end
  end
end
