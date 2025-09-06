# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid-email').for(:email) }
    it { is_expected.not_to allow_value('').for(:email) }

    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end

  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      created_user = create(:user)
      expect(created_user).to be_valid
    end

    it 'creates a user with valid attributes' do
      created_user = create(:user)
      expect(created_user).to be_persisted
      expect(created_user.email).to be_present
      expect(created_user.encrypted_password).to be_present
    end
  end

  describe 'password authentication' do
    let(:password) { 'secure_password' }
    let(:user) { create(:user, password: password) }

    it 'authenticates with correct password' do
      expect(user.valid_password?(password)).to be true
    end

    it 'does not authenticate with incorrect password' do
      expect(user.valid_password?('wrong_password')).to be false
    end
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it 'has one producer profile' do
      expect(user).to have_one(:producer_profile)
    end

    it 'has one vet profile' do
      expect(user).to have_one(:vet_profile)
    end
  end

  describe '#profile' do
    context 'when user has a producer profile' do
      it 'returns the producer profile' do
        user = create(:user_with_producer_profile)

        expect(user.profile).to eq(user.producer_profile)
      end
    end

    context 'when user has no profile' do
      it 'returns nil' do
        user = build(:user_without_profile)

        expect(user.profile).to be_nil
      end
    end
  end
end
