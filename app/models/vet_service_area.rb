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
