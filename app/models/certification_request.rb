# frozen_string_literal: true

# == Schema Information
#
# Table name: certification_requests
#
#  id                    :bigint           not null, primary key
#  address               :string
#  intended_animal_group :integer
#  scheduled_date        :date             not null
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

  validates :address, :locality, :producer_profile, :scheduled_date, :intended_animal_group, presence: true

  enum :status, { created: 'created',
                  assigned: 'assigned',
                  executed: 'executed',
                  canceled: 'canceled',
                  rejected: 'rejected' }
end
