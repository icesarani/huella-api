# frozen_string_literal: true

# == Schema Information
#
# Table name: localities
#
#  id          :integer          not null, primary key
#  indec_code  :string
#  name        :string
#  category    :string
#  province_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_localities_on_indec_code   (indec_code) UNIQUE
#  index_localities_on_province_id  (province_id)
#

FactoryBot.define do
  factory :locality do
    sequence(:indec_code) { |n| "06#{n.to_s.rjust(9, '0')}" }
    sequence(:name) { |n| "Localidad #{n}" }
    category { :simple_locality }
    association :province

    trait :city do
      category { :city }
    end

    trait :la_plata do
      indec_code { '06001010000' }
      name { 'La Plata' }
      category { :city }
      association :province, :buenos_aires
    end

    trait :mar_del_plata do
      indec_code { '06270070000' }
      name { 'Mar del Plata' }
      category { :city }
      association :province, :buenos_aires
    end
  end
end
