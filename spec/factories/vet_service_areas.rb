# frozen_string_literal: true

# == Schema Information
#
# Table name: vet_service_areas
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  locality_id    :bigint           not null
#  vet_profile_id :bigint           not null
#
# Indexes
#
#  index_vet_service_areas_on_locality_id     (locality_id)
#  index_vet_service_areas_on_vet_profile_id  (vet_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (locality_id => localities.id)
#  fk_rails_...  (vet_profile_id => vet_profiles.id)
#

FactoryBot.define do
  factory :vet_service_area do
    association :vet_profile
    association :locality
  end
end
