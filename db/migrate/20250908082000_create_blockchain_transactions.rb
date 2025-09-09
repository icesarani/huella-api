# frozen_string_literal: true

class CreateBlockchainTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :blockchain_transactions do |t|
      t.string :transaction_hash, null: false
      t.bigint :block_number
      t.string :status, null: false, default: 'pending'
      t.bigint :gas_used
      t.string :network, null: false
      t.string :contract_address, null: false
      t.text :error_message
      t.json :raw_response

      t.timestamps
    end

    add_index :blockchain_transactions, :transaction_hash, unique: true
    add_index :blockchain_transactions, :status
    add_index :blockchain_transactions, %i[network contract_address]
  end
end
