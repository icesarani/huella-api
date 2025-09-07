# frozen_string_literal: true

# == Schema Information
#
# Table name: certification_requests
#
#  id                    :bigint           not null, primary key
#  address               :string
#  declared_lot_age      :enum             not null
#  declared_lot_health   :enum             not null
#  declared_lot_weight   :enum             not null
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
  belongs_to :vet_profile, optional: true
  belongs_to :producer_profile

  validates :address, :locality, :producer_profile, :preferred_time_range, :intended_animal_group,
            :declared_lot_weight, :declared_lot_age, :declared_lot_health, presence: true

  enum :status, { created: 'created',
                  assigned: 'assigned',
                  executed: 'executed',
                  canceled: 'canceled',
                  rejected: 'rejected' }

  enum :scheduled_time, { morning: 'morning', afternoon: 'afternoon' }

  enum :declared_lot_weight, { skinny: 'skinny', average: 'average', heavy: 'heavy' }, prefix: true
  enum :declared_lot_age, { new_born: 'new_born', young: 'young', mature: 'mature', adult: 'adult' }, prefix: true
  enum :declared_lot_health, { unhealthy: 'unhealthy', common: 'common', healthy: 'healthy' }, prefix: true
end
