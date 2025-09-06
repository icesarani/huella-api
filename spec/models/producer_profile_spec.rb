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

require 'rails_helper'

RSpec.describe ProducerProfile, type: :model do
  subject(:producer_profile) { build(:producer_profile) }

  describe 'associations' do
    it 'belongs to user' do
      expect(subject).to belong_to(:user)
    end

    it 'belongs to blockchain wallet' do
      expect(subject.blockchain_wallet).to be_a(BlockchainWallet)
    end
  end

  describe 'validations' do
    it 'validates presence of cuig number' do
      expect(subject).to validate_presence_of(:cuig_number)
    end

    it 'validates presence of renspa number' do
      expect(subject).to validate_presence_of(:renspa_number)
    end

    it 'validates presence of identity card' do
      expect(subject).to validate_presence_of(:identity_card)
    end

    it 'validates presence of name' do
      expect(subject).to validate_presence_of(:name)
    end

    it 'validates uniqueness of cuig number' do
      created_profile = create(:producer_profile)
      expect(created_profile).to validate_uniqueness_of(:cuig_number)
    end

    it 'validates uniqueness of renspa number' do
      created_profile = create(:producer_profile)
      expect(created_profile).to validate_uniqueness_of(:renspa_number).case_insensitive
    end

    it 'validates uniqueness of identity card' do
      created_profile = create(:producer_profile)
      expect(created_profile).to validate_uniqueness_of(:identity_card).case_insensitive
    end
  end

  describe 'unique constraints' do
    context 'user uniqueness' do
      it 'allows only one producer profile per user' do
        user = create(:user_without_profile)
        create(:producer_profile, user: user)

        expect do
          create(:producer_profile, user: user)
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(producer_profile).to be_valid
    end

    it 'generates unique cuig numbers' do
      profile1 = create(:producer_profile)
      profile2 = create(:producer_profile)

      expect(profile1.cuig_number).not_to eq(profile2.cuig_number)
    end

    it 'generates unique renspa numbers' do
      profile1 = create(:producer_profile)
      profile2 = create(:producer_profile)

      expect(profile1.renspa_number).not_to eq(profile2.renspa_number)
    end

    it 'generates unique identity cards' do
      profile1 = create(:producer_profile)
      profile2 = create(:producer_profile)

      expect(profile1.identity_card).not_to eq(profile2.identity_card)
    end

    it 'creates associated user and wallet' do
      profile = create(:producer_profile)

      expect(profile.user).to be_present
      expect(profile.blockchain_wallet).to be_present
    end
  end

  describe 'user profile relationship' do
    it 'is accessible through user profile method' do
      profile = create(:producer_profile)

      expect(profile.user.profile).to eq(profile)
    end
  end
end
