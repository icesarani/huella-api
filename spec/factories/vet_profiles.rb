# frozen_string_literal: true

# == Schema Information
#
# Table name: vet_profiles
#
#  id                   :integer          not null, primary key
#  first_name           :string           not null
#  last_name            :string           not null
#  identity_card        :string           not null
#  license_number       :string           not null
#  user_id              :integer          not null
#  blockchain_wallet_id :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_vet_profiles_on_blockchain_wallet_id  (blockchain_wallet_id) UNIQUE
#  index_vet_profiles_on_identity_card         (identity_card) UNIQUE
#  index_vet_profiles_on_license_number        (license_number) UNIQUE
#  index_vet_profiles_on_user_id               (user_id) UNIQUE
#

FactoryBot.define do
  factory :vet_profile do
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:identity_card) { |n| "ID#{n.to_s.rjust(8, '0')}" }
    sequence(:license_number) { |n| "LIC#{n.to_s.rjust(6, '0')}" }
    association :user
    association :blockchain_wallet
  end
end
