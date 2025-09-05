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

class VetServiceArea < ApplicationRecord
  belongs_to :vet_profile
  belongs_to :locality

  validates :vet_profile_id, uniqueness: { scope: :locality_id }

  scope :by_province, ->(province_id) { joins(:locality).where(locality: { province_id: province_id }) }

  def province
    locality.province
  end

  def to_s
    "#{vet_profile.user.email} - #{locality}"
  end
end
