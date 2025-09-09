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
class BlockchainTransaction < ApplicationRecord
  has_one :certification_document, inverse_of: :blockchain_transaction, dependent: :nullify

  validates :transaction_hash, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed failed] }
  validates :network, presence: true
  validates :contract_address, presence: true

  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    failed: 'failed'
  }, prefix: true

  scope :for_network, ->(network) { where(network: network) }
  scope :for_contract, ->(address) { where(contract_address: address) }
  scope :recent, -> { order(created_at: :desc) }

  def confirmed?
    status_confirmed?
  end

  def failed?
    status_failed?
  end

  def pending?
    status_pending?
  end

  def blockchain_url
    case network.downcase
    when 'amoy', 'polygon-amoy'
      "https://amoy.polygonscan.com/tx/#{transaction_hash}"
    when 'polygon', 'matic'
      "https://polygonscan.com/tx/#{transaction_hash}"
    when 'ethereum', 'mainnet'
      "https://etherscan.io/tx/#{transaction_hash}"
    end
  end

  def network_name
    case network.downcase
    when 'amoy', 'polygon-amoy'
      'Polygon Amoy Testnet'
    when 'polygon', 'matic'
      'Polygon Mainnet'
    when 'ethereum', 'mainnet'
      'Ethereum Mainnet'
    else
      network.titleize
    end
  end

  def gas_cost_eth
    return nil unless gas_used.present?

    # This would need gas price to calculate actual cost
    # For now, just return gas used
    gas_used
  end
end
