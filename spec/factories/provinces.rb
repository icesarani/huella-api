# frozen_string_literal: true

# == Schema Information
#
# Table name: provinces
#
#  id         :bigint           not null, primary key
#  indec_code :string
#  iso_code   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_provinces_on_indec_code  (indec_code) UNIQUE
#

FactoryBot.define do
  factory :province do
    sequence(:indec_code) { |n| (10 + (n % 90)).to_s }
    sequence(:name) { |n| "Provincia #{n}" }
    sequence(:iso_code) { |n| "AR-#{('A'.ord + (n % 26)).chr}" }

    trait :buenos_aires do
      indec_code { '06' }
      name { 'Buenos Aires' }
      iso_code { 'AR-B' }
    end
  end
end
