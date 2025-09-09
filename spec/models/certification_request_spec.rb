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
    it { is_expected.to validate_presence_of(:cattle_breed) }

    it {
      is_expected.to validate_numericality_of(:declared_lot_weight).is_greater_than(0).is_less_than_or_equal_to(2000)
    }
    it { is_expected.to validate_numericality_of(:declared_lot_age).is_greater_than(0).is_less_than_or_equal_to(240) }
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
        declared_lot_weight: 450,
        declared_lot_age: 24,
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

  describe 'scopes' do
    describe '.open' do
      let(:producer_profile) { create(:producer_profile) }
      let(:vet_profile) { create(:vet_profile) }
      let(:locality) { create(:locality) }

      let!(:created_request) do
        create(:certification_request, :created, producer_profile: producer_profile, locality: locality)
      end
      let!(:assigned_request) do
        create(:certification_request, :assigned, producer_profile: producer_profile, locality: locality,
                                                  vet_profile: vet_profile)
      end
      let!(:executed_request) do
        create(:certification_request, :executed, producer_profile: producer_profile, locality: locality,
                                                  vet_profile: vet_profile)
      end
      let!(:canceled_request) do
        create(:certification_request, :canceled, producer_profile: producer_profile, locality: locality)
      end
      let!(:rejected_request) do
        create(:certification_request, :rejected, producer_profile: producer_profile, locality: locality)
      end

      context 'when filtering by producer profile' do
        it 'returns only created and assigned requests for the producer' do
          open_requests = described_class.open(profile: producer_profile)

          expect(open_requests).to contain_exactly(created_request, assigned_request)
          expect(open_requests).not_to include(executed_request)
          expect(open_requests).not_to include(canceled_request)
          expect(open_requests).not_to include(rejected_request)
        end

        it 'excludes requests from other producers' do
          other_producer = create(:producer_profile)
          other_request = create(:certification_request, :created, producer_profile: other_producer, locality: locality)

          open_requests = described_class.open(profile: producer_profile)

          expect(open_requests).not_to include(other_request)
        end
      end

      context 'when filtering by vet profile' do
        it 'returns only assigned requests for the veterinarian' do
          open_requests = described_class.open(profile: vet_profile)

          expect(open_requests).to contain_exactly(assigned_request)
          expect(open_requests).not_to include(created_request)
          expect(open_requests).not_to include(executed_request)
        end

        it 'excludes requests assigned to other veterinarians' do
          other_vet = create(:vet_profile)
          other_vet_request = create(:certification_request, :assigned, producer_profile: producer_profile,
                                                                        locality: locality, vet_profile: other_vet)

          open_requests = described_class.open(profile: vet_profile)

          expect(open_requests).not_to include(other_vet_request)
        end
      end

      context 'when dealing with scheduled dates' do
        let!(:future_scheduled_request) do
          create(:certification_request, :assigned,
                 producer_profile: producer_profile,
                 locality: locality,
                 vet_profile: vet_profile,
                 scheduled_date: 1.day.from_now)
        end
        let!(:today_scheduled_request) do
          create(:certification_request, :assigned,
                 producer_profile: producer_profile,
                 locality: locality,
                 vet_profile: vet_profile,
                 scheduled_date: Time.zone.today)
        end
        let!(:past_scheduled_request) do
          create(:certification_request, :assigned,
                 producer_profile: producer_profile,
                 locality: locality,
                 vet_profile: vet_profile,
                 scheduled_date: 1.day.ago)
        end

        it 'includes requests with null scheduled_date' do
          open_requests = described_class.open(profile: producer_profile)

          expect(open_requests).to include(created_request)
          expect(open_requests).to include(assigned_request)
        end

        it 'includes requests scheduled for today or future' do
          open_requests = described_class.open(profile: producer_profile)

          expect(open_requests).to include(future_scheduled_request)
          expect(open_requests).to include(today_scheduled_request)
        end

        it 'excludes requests scheduled in the past' do
          open_requests = described_class.open(profile: producer_profile)

          expect(open_requests).not_to include(past_scheduled_request)
        end
      end

      context 'when profile has no certification requests' do
        let(:empty_producer) { create(:producer_profile) }
        let(:empty_vet) { create(:vet_profile) }

        it 'returns empty relation for producer with no requests' do
          open_requests = described_class.open(profile: empty_producer)

          expect(open_requests).to be_empty
        end

        it 'returns empty relation for vet with no assigned requests' do
          open_requests = described_class.open(profile: empty_vet)

          expect(open_requests).to be_empty
        end
      end
    end
  end
end
