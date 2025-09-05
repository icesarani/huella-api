# frozen_string_literal: true

# == Schema Information
#
# Table name: producer_profiles
#
#  id                   :bigint           not null, primary key
#  cuig_number          :string           not null
#  identity_card        :string           not null
#  name                 :string           not null
#  renspa_number        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  blockchain_wallet_id :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_producer_profiles_on_blockchain_wallet_id  (blockchain_wallet_id) UNIQUE
#  index_producer_profiles_on_cuig_number           (cuig_number) UNIQUE
#  index_producer_profiles_on_identity_card         (identity_card) UNIQUE
#  index_producer_profiles_on_renspa_number         (renspa_number) UNIQUE
#  index_producer_profiles_on_user_id               (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (blockchain_wallet_id => blockchain_wallets.id)
#  fk_rails_...  (user_id => users.id)
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
