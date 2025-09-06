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

class ProducerProfile < ApplicationRecord
  belongs_to :user, optional: false, inverse_of: :producer_profile
  belongs_to :blockchain_wallet, required: true, inverse_of: :producer_profile

  validates :cuig_number, :renspa_number, :identity_card, :name, presence: true
  validates :cuig_number, uniqueness: true
  validates :renspa_number, uniqueness: { case_sensitive: false }
  validates :identity_card, uniqueness: { case_sensitive: false }

  before_validation :ensure_blockchain_wallet, on: :create

  private

  def ensure_blockchain_wallet
    return if blockchain_wallet.present?

    self.blockchain_wallet = BlockchainWallet.create!(address: generate_wallet_address)
  end

  def generate_wallet_address
    "0x#{SecureRandom.hex(20)}"
  end
end
