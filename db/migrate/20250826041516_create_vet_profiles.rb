# frozen_string_literal: true

class CreateVetProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :vet_profiles do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :identity_card, null: false
      t.string :license_number, null: false
      t.references :user, null: false, foreign_key: true
      t.references :blockchain_wallet, null: false, foreign_key: true

      t.timestamps
    end

    add_index :vet_profiles, :identity_card, unique: true
    add_index :vet_profiles, :license_number, unique: true
  end
end
