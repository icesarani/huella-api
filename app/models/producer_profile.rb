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

class ProducerProfile < ApplicationRecord
  belongs_to :user, optional: false, inverse_of: :producer_profile
  belongs_to :blockchain_wallet, optional: false, inverse_of: :producer_profile

  validates :cuig_number, :renspa_number, :identity_card, :name, presence: true
  validates :cuig_number, uniqueness: true
  validates :renspa_number, uniqueness: true
  validates :identity_card, uniqueness: true
end
