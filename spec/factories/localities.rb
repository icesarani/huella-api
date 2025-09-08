# frozen_string_literal: true

# == Schema Information
#
# Table name: localities
#
#  id          :bigint           not null, primary key
#  category    :string
#  indec_code  :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  province_id :bigint           not null
#
# Indexes
#
#  index_localities_on_indec_code   (indec_code) UNIQUE
#  index_localities_on_province_id  (province_id)
#
# Foreign Keys
#
#  fk_rails_...  (province_id => provinces.id)
#

FactoryBot.define do
  factory :locality do
    indec_code { "06#{rand(100_000_000..999_999_999)}" }
    name { "Localidad #{rand(1000..9999)}" }
    category { 'simple_locality' }
    association :province

    trait :city do
      category { 'city' }
    end

    trait :la_plata do
      indec_code { '06001010000' }
      name { 'La Plata' }
      category { 'city' }
      association :province, :buenos_aires
    end

    trait :mar_del_plata do
      indec_code { '06270070000' }
      name { 'Mar del Plata' }
      category { 'city' }
      association :province, :buenos_aires
    end
  end
end
