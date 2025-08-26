# frozen_string_literal: true

class CreateProducerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :producer_profiles do |t|
      t.string :cuig_number, null: false
      t.string :renspa_number, null: false
      t.string :identity_card, null: false
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.references :blockchain_wallet, null: false, foreign_key: true

      t.timestamps
    end

    add_index :producer_profiles, :cuig_number, unique: true
    add_index :producer_profiles, :renspa_number, unique: true
    add_index :producer_profiles, :identity_card, unique: true
  end
end
