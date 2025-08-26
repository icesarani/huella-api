# frozen_string_literal: true

class UpdateProfileIndexesToUnique < ActiveRecord::Migration[8.0]
  def change
    # Make wallet indexes unique to ensure 1 wallet = 1 profile
    remove_index :vet_profiles, :blockchain_wallet_id
    add_index :vet_profiles, :blockchain_wallet_id, unique: true

    remove_index :producer_profiles, :blockchain_wallet_id
    add_index :producer_profiles, :blockchain_wallet_id, unique: true

    # Make user indexes unique to ensure 1 user = 1 profile type
    remove_index :vet_profiles, :user_id
    add_index :vet_profiles, :user_id, unique: true

    remove_index :producer_profiles, :user_id
    add_index :producer_profiles, :user_id, unique: true
  end
end
