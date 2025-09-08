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
    indec_code { rand(10..99).to_s }
    name { "Provincia #{rand(1000..9999)}" }
    iso_code { "AR-#{('A'.ord + rand(0..25)).chr}" }

    trait :buenos_aires do
      indec_code { '06' }
      name { 'Buenos Aires' }
      iso_code { 'AR-B' }
    end
  end
end
