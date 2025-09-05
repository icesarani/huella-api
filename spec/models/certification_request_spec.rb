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
require 'rails_helper'

RSpec.describe CertificationRequest, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:locality) }
    it { is_expected.to belong_to(:vet_profile).optional }
    it { is_expected.to belong_to(:producer_profile) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:locality) }
    it { is_expected.to validate_presence_of(:producer_profile) }
    it { is_expected.to validate_presence_of(:scheduled_date) }
    it { is_expected.to validate_presence_of(:intended_animal_group) }
  end

  describe 'enums' do
    it 'defines status enum with expected values' do
      expect(described_class.statuses).to eq(
        'created' => 'created',
        'assigned' => 'assigned',
        'executed' => 'executed',
        'canceled' => 'canceled',
        'rejected' => 'rejected'
      )
    end
  end
end
