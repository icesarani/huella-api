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

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :vet_profile do # rubocop:disable Metrics/BlockLength
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:identity_card) { |n| "ID#{n.to_s.rjust(8, '0')}" }
    sequence(:license_number) { |n| "LIC#{n.to_s.rjust(6, '0')}" }
    association :blockchain_wallet

    # Build user for both build and create
    after(:build) do |vet_profile|
      vet_profile.user = build(:user_without_profile) unless vet_profile.user
    end

    # Save user before creating profile
    before(:create) do |vet_profile|
      vet_profile.user.save!(validate: false) if vet_profile.user&.new_record?
    end

    # @example Creating a vet profile with service areas
    #   vet_profile = create(:vet_profile, :with_service_areas, service_areas_count: 3)
    #   This will create a vet profile with 3 associated service areas.
    trait :with_service_areas do
      transient do
        service_areas_count { 2 }
      end

      after(:create) do |vet_profile, evaluator|
        create_list(:vet_service_area, evaluator.service_areas_count, vet_profile: vet_profile)
      end
    end

    # @example Creating a vet profile with work schedule
    #   vet_profile = create(:vet_profile, :with_work_schedule)
    #   This will create a vet profile with a basic work schedule.
    trait :with_work_schedule do
      after(:create) do |vet_profile|
        create(:vet_work_schedule, vet_profile: vet_profile)
      end
    end

    # @example Creating a vet profile with full-time work schedule
    #   vet_profile = create(:vet_profile, :with_full_time_schedule)
    #   This will create a vet profile with a full-time work schedule.
    trait :with_full_time_schedule do
      after(:create) do |vet_profile|
        create(:vet_work_schedule, :full_time, vet_profile: vet_profile)
      end
    end

    # @example Creating a vet profile with service areas and work schedule
    #   vet_profile = create(:vet_profile, :with_service_areas_and_schedule)
    #   This will create a complete vet profile with both service areas and work schedule.
    trait :with_service_areas_and_schedule do
      transient do
        service_areas_count { 2 }
      end

      after(:create) do |vet_profile, evaluator|
        create_list(:vet_service_area, evaluator.service_areas_count, vet_profile: vet_profile)
        create(:vet_work_schedule, :weekday_mornings, vet_profile: vet_profile)
      end
    end
  end
end
