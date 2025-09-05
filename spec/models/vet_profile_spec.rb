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

require 'rails_helper'

RSpec.describe VetProfile, type: :model do
  subject(:vet_profile) { build(:vet_profile) }

  describe 'associations' do
    it 'belongs to user' do
      expect(subject).to belong_to(:user)
    end

    it 'belongs to blockchain wallet' do
      expect(subject).to belong_to(:blockchain_wallet)
    end
  end

  describe 'validations' do
    it 'validates presence of first name' do
      expect(subject).to validate_presence_of(:first_name)
    end

    it 'validates presence of last name' do
      expect(subject).to validate_presence_of(:last_name)
    end

    it 'validates presence of identity card' do
      expect(subject).to validate_presence_of(:identity_card)
    end

    it 'validates presence of license number' do
      expect(subject).to validate_presence_of(:license_number)
    end

    it 'validates uniqueness of identity card' do
      expect(subject).to validate_uniqueness_of(:identity_card)
    end

    it 'validates uniqueness of license number' do
      expect(subject).to validate_uniqueness_of(:license_number)
    end
  end

  describe 'unique constraints' do
    context 'user uniqueness' do
      it 'allows only one vet profile per user' do
        user = create(:user)
        create(:vet_profile, user: user)

        expect do
          create(:vet_profile, user: user)
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(vet_profile).to be_valid
    end

    it 'generates unique identity cards' do
      profile1 = create(:vet_profile)
      profile2 = create(:vet_profile)

      expect(profile1.identity_card).not_to eq(profile2.identity_card)
    end

    it 'generates unique license numbers' do
      profile1 = create(:vet_profile)
      profile2 = create(:vet_profile)

      expect(profile1.license_number).not_to eq(profile2.license_number)
    end

    it 'creates associated user and wallet' do
      profile = create(:vet_profile)

      expect(profile.user).to be_present
      expect(profile.blockchain_wallet).to be_present
    end
  end

  describe 'user profile relationship' do
    it 'is accessible through user profile method' do
      profile = create(:vet_profile)

      expect(profile.user.profile).to eq(profile)
    end
  end
end
