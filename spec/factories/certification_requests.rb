# frozen_string_literal: true

# == Schema Information
#
# Table name: certification_requests
#
#  id                    :bigint           not null, primary key
#  address               :string
#  cattle_breed          :enum             not null
#  declared_lot_age      :integer          not null
#  declared_lot_weight   :integer          not null
#  intended_animal_group :integer
#  preferred_time_range  :tstzrange        not null
#  scheduled_date        :date
#  scheduled_time        :enum
#  status                :enum             default("created"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  locality_id           :bigint           not null
#  producer_profile_id   :bigint           not null
#  vet_profile_id        :bigint
#
# Indexes
#
#  index_certification_requests_on_locality_id          (locality_id)
#  index_certification_requests_on_producer_profile_id  (producer_profile_id)
#  index_certification_requests_on_vet_profile_id       (vet_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (locality_id => localities.id)
#  fk_rails_...  (producer_profile_id => producer_profiles.id)
#  fk_rails_...  (vet_profile_id => vet_profiles.id)
#
FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :certification_request do # rubocop:disable Metrics/BlockLength
    status { CertificationRequest.statuses.keys.first }
    address { Faker::Address.full_address }
    locality
    vet_profile { nil }
    producer_profile
    intended_animal_group { 50 }
    declared_lot_weight { rand(300..800) }
    declared_lot_age { rand(6..60) }
    cattle_breed { CertificationRequest.cattle_breeds.keys.sample }
    preferred_time_range { (Time.current..Time.current + 30.days) }

    # @example Creating a certification request with file upload
    #   certification_request = create(:certification_request, :with_file_upload)
    trait :with_file_upload do
      after(:create) do |certification_request|
        create(:file_upload, certification_request: certification_request)
      end
    end

    # @example Creating a certification request with processed file upload
    #   certification_request = create(:certification_request, :with_processed_file_upload)
    trait :with_processed_file_upload do
      after(:create) do |certification_request|
        create(:file_upload, :processed, certification_request: certification_request)
      end
    end

    # @example Creating a certification request with specific cattle breed
    #   certification_request = create(:certification_request, :angus_cattle)
    trait :angus_cattle do
      cattle_breed { 'angus' }
    end

    trait :with_vet do
      association :vet_profile, factory: :vet_profile
    end

    trait :scheduled_morning do
      scheduled_date { Date.current + 5.days }
      scheduled_time { 'morning' }
      preferred_time_range { (Time.current..Time.current + 30.days) }
      association :vet_profile, factory: :vet_profile
    end

    # Status traits
    trait :created do
      status { 'created' }
      vet_profile { nil }
    end

    trait :assigned do
      status { 'assigned' }
      association :vet_profile, factory: :vet_profile
    end

    trait :executed do
      status { 'executed' }
      association :vet_profile, factory: :vet_profile
    end

    trait :canceled do
      status { 'canceled' }
    end

    trait :rejected do
      status { 'rejected' }
    end
  end
end
