# frozen_string_literal: true

# == Schema Information
#
# Table name: certification_requests
#
#  id                    :bigint           not null, primary key
#  address               :string
#  cattle_breed          :enum             not null
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
require 'rails_helper'

RSpec.describe CertificationRequest, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:locality) }
    it { is_expected.to belong_to(:vet_profile).optional }
    it { is_expected.to belong_to(:producer_profile) }
    it { is_expected.to have_one(:file_upload).dependent(:destroy).inverse_of(:certification_request) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:locality) }
    it { is_expected.to validate_presence_of(:producer_profile) }
    it { is_expected.to validate_presence_of(:preferred_time_range) }
    it { is_expected.to validate_presence_of(:intended_animal_group) }
    it { is_expected.to validate_presence_of(:declared_lot_weight) }
    it { is_expected.to validate_presence_of(:declared_lot_age) }
    it { is_expected.to validate_presence_of(:declared_lot_health) }
    it { is_expected.to validate_presence_of(:cattle_breed) }
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

    it 'defines cattle_breed enum with expected values' do
      expect(described_class.cattle_breeds).to eq(
        'angus' => 'angus',
        'hereford' => 'hereford',
        'brahman' => 'brahman',
        'charolais' => 'charolais',
        'limousin' => 'limousin',
        'simmental' => 'simmental',
        'holstein' => 'holstein',
        'jersey' => 'jersey',
        'shorthorn' => 'shorthorn',
        'other' => 'other'
      )
    end
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for file_upload' do
      request = described_class.new(
        address: 'Test Address',
        locality: create(:locality),
        producer_profile: create(:producer_profile),
        intended_animal_group: 50,
        declared_lot_weight: 'average',
        declared_lot_age: 'mature',
        declared_lot_health: 'healthy',
        cattle_breed: 'angus',
        preferred_time_range: (Time.current..Time.current + 30.days),
        file_upload_attributes: {
          ai_analyzed_age: '2.3 years',
          ai_analyzed_weight: '485 kg',
          ai_analyzed_breed: 'Angus'
        }
      )

      expect(request.file_upload).to be_present
    end
  end

  describe 'file upload integration' do
    let(:certification_request) { create(:certification_request) }

    it 'can create a certification request with file upload' do
      certification_request = create(:certification_request, :with_file_upload)

      expect(certification_request.file_upload).to be_present
      expect(certification_request.file_upload.file).to be_attached
    end

    it 'destroys associated file upload when certification request is destroyed' do
      file_upload_id = create(:file_upload, certification_request: certification_request).id

      certification_request.destroy

      expect(FileUpload.find_by(id: file_upload_id)).to be_nil
    end
  end
end
