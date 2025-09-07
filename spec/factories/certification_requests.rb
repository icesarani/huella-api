# frozen_string_literal: true

# == Schema Information
#
# Table name: certification_requests
#
#  id                    :bigint           not null, primary key
#  address               :string
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
FactoryBot.define do
  factory :certification_request do
    status { CertificationRequest.statuses.keys.first }
    address { Faker::Address.full_address }
    locality
    vet_profile { nil }
    producer_profile
    intended_animal_group { 50 }

    trait :with_vet do
      association :vet_profile, factory: :vet_profile
    end

    trait :scheduled_morning do
      scheduled_date { Date.current + 5.days }
      scheduled_time { 'morning' }
      preferred_time_range { (Time.current..Time.current + 30.days) }
      association :vet_profile, factory: :vet_profile
    end
  end
end
