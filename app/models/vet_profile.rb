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

class VetProfile < ApplicationRecord
  belongs_to :user, inverse_of: :vet_profile, optional: false
  belongs_to :blockchain_wallet, optional: false, inverse_of: :vet_profile
  has_many :vet_service_areas, dependent: :destroy
  has_many :localities, through: :vet_service_areas

  validates :first_name, :last_name, :identity_card, :license_number, presence: true
  validates :identity_card, uniqueness: true
  validates :license_number, uniqueness: true

  def provinces
    Province.joins(:localities).merge(localities).distinct
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
