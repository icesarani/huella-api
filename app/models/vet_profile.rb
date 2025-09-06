# frozen_string_literal: true

# == Schema Information
#
# Table name: vet_profiles
#
#  id                   :bigint           not null, primary key
#  first_name           :string           not null
#  identity_card        :string           not null
#  last_name            :string           not null
#  license_number       :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  blockchain_wallet_id :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_vet_profiles_on_blockchain_wallet_id  (blockchain_wallet_id) UNIQUE
#  index_vet_profiles_on_identity_card         (identity_card) UNIQUE
#  index_vet_profiles_on_license_number        (license_number) UNIQUE
#  index_vet_profiles_on_user_id               (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (blockchain_wallet_id => blockchain_wallets.id)
#  fk_rails_...  (user_id => users.id)
#

class VetProfile < ApplicationRecord
  belongs_to :user, inverse_of: :vet_profile, optional: false
  belongs_to :blockchain_wallet, required: true, inverse_of: :vet_profile
  has_many :vet_service_areas, dependent: :destroy
  has_many :localities, through: :vet_service_areas

  validates :first_name, :last_name, :identity_card, :license_number, presence: true
  validates :identity_card, uniqueness: { case_sensitive: false }
  validates :license_number, uniqueness: true

  before_validation :ensure_blockchain_wallet, on: :create

  def provinces
    Province.joins(:localities).merge(localities).distinct
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  # Ensure a blockchain wallet is associated with the profile
  # If not, create one using the Blockchain::WalletCreationService
  # to handle wallet creation logic.
  # This abstracts wallet creation and ensures consistency.
  def ensure_blockchain_wallet
    return if blockchain_wallet.present?

    self.blockchain_wallet = Blockchain::WalletCreationService.new.call!
  end
end
