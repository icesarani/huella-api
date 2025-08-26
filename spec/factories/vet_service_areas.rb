# frozen_string_literal: true

# == Schema Information
#
# Table name: vet_service_areas
#
#  id             :integer          not null, primary key
#  vet_profile_id :integer          not null
#  locality_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_vet_service_areas_on_locality_id     (locality_id)
#  index_vet_service_areas_on_vet_profile_id  (vet_profile_id)
#

FactoryBot.define do
  factory :vet_service_area do
    association :vet_profile
    association :locality
  end
end
