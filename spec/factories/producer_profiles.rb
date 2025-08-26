# frozen_string_literal: true

# == Schema Information
#
# Table name: producer_profiles
#
#  id                   :integer          not null, primary key
#  cuig_number          :string           not null
#  renspa_number        :string           not null
#  identity_card        :string           not null
#  name                 :string           not null
#  user_id              :integer          not null
#  blockchain_wallet_id :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_producer_profiles_on_blockchain_wallet_id  (blockchain_wallet_id) UNIQUE
#  index_producer_profiles_on_cuig_number           (cuig_number) UNIQUE
#  index_producer_profiles_on_identity_card         (identity_card) UNIQUE
#  index_producer_profiles_on_renspa_number         (renspa_number) UNIQUE
#  index_producer_profiles_on_user_id               (user_id) UNIQUE
#

FactoryBot.define do
  factory :producer_profile do
    sequence(:cuig_number) { |n| "CUIG#{n.to_s.rjust(6, '0')}" }
    sequence(:renspa_number) { |n| "RENSPA#{n.to_s.rjust(5, '0')}" }
    sequence(:identity_card) { |n| "PROD#{n.to_s.rjust(8, '0')}" }
    name { 'Farm Producer' }
    association :user
    association :blockchain_wallet
  end
end
