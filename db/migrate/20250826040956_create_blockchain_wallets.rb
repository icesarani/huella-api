# frozen_string_literal: true

class CreateBlockchainWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :blockchain_wallets do |t|
      t.string :address
      t.string :mnemonic_phrase
      t.string :private_key

      t.timestamps
    end

    add_index :blockchain_wallets, :address, unique: true
  end
end
