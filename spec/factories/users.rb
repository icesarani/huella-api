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

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :user do
    sequence(:email) { |n| "jdoe#{n}@test.com" }
    password { 'password' }

    # Save without validation first, then add profile
    to_create do |instance|
      instance.save!(validate: false)
      FactoryBot.create(:producer_profile, user: instance) unless instance.producer_profile || instance.vet_profile
    end

    factory :user_without_profile do
      after(:build) do |user|
        # Skip profile validation for this factory
      end

      to_create do |instance|
        instance.save!(validate: false)
      end
    end

    factory :user_with_producer_profile do
      to_create do |instance|
        instance.save!(validate: false)
        FactoryBot.create(:producer_profile, user: instance) unless instance.producer_profile
      end
    end

    factory :user_with_vet_profile do
      to_create do |instance|
        instance.save!(validate: false)
        FactoryBot.create(:vet_profile, user: instance) unless instance.vet_profile
      end
    end
  end
end
