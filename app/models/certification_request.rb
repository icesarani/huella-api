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
class CertificationRequest < ApplicationRecord
  belongs_to :locality
  belongs_to :vet_profile, optional: true, inverse_of: :certification_requests
  belongs_to :producer_profile, inverse_of: :certification_requests
  has_one :file_upload, dependent: :destroy, inverse_of: :certification_request
  has_one :certified_lot, dependent: :destroy

  accepts_nested_attributes_for :file_upload, allow_destroy: true, reject_if: :all_blank

  validates :address, :locality, :producer_profile, :preferred_time_range, :intended_animal_group,
            :declared_lot_weight, :declared_lot_age, :cattle_breed, presence: true

  validates :declared_lot_weight, numericality: { greater_than: 0, less_than_or_equal_to: 2000 }
  validates :declared_lot_age, numericality: { greater_than: 0, less_than_or_equal_to: 240 }

  enum :status, { created: 'created',
                  assigned: 'assigned',
                  executed: 'executed',
                  canceled: 'canceled',
                  rejected: 'rejected' }

  enum :scheduled_time, { morning: 'morning', afternoon: 'afternoon' }

  enum :cattle_breed, { angus: 'angus',
                        hereford: 'hereford',
                        brahman: 'brahman',
                        charolais: 'charolais',
                        limousin: 'limousin',
                        simmental: 'simmental',
                        holstein: 'holstein',
                        jersey: 'jersey',
                        shorthorn: 'shorthorn',
                        other: 'other' }

  # Scope to retrieve open certification requests (created or assigned) for a given profile
  # @param profile [ProducerProfile, VetProfile] The profile to filter certification requests
  # @return [ActiveRecord::Relation] ActiveRecord relation with the filtered certification requests
  scope :open, lambda { |profile:|
    profile.certification_requests
           .where(status: %w[created assigned])
           .and(where('scheduled_date IS NULL OR scheduled_date >= ?', Time.zone.today))
  }
end
