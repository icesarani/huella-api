# frozen_string_literal: true

# == Schema Information
#
# Table name: cattle_certifications
#
#  id                         :bigint           not null, primary key
#  alternative_code           :string
#  brucellosis_diagnosis      :string
#  category                   :enum             not null
#  comments                   :string
#  corporal_condition         :integer
#  cuig_code                  :string
#  data_taken_at              :datetime
#  dental_chronology          :enum
#  estimated_weight           :integer
#  gender                     :enum             not null
#  geolocation_points         :jsonb
#  pregnancy_diagnosis_method :enum
#  pregnancy_service_range    :tstzrange
#  pregnant                   :boolean
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  certified_lot_id           :bigint           not null
#
# Indexes
#
#  index_cattle_certifications_on_certified_lot_id  (certified_lot_id)
#
# Foreign Keys
#
#  fk_rails_...  (certified_lot_id => certified_lots.id)
#
require 'rails_helper'

RSpec.describe CattleCertification, type: :model do
  subject(:cattle_certification) { build(:cattle_certification) }

  describe 'associations' do
    it { is_expected.to belong_to(:certified_lot).inverse_of(:cattle_certifications) }
    it { is_expected.to have_one_attached(:photo) }
  end

  describe 'enums' do
    describe 'category' do
      it 'defines the correct category values' do
        expect(CattleCertification.categories.keys).to contain_exactly('unweaned_calf', 'weaned_heifer', 'weaned_steer')
      end
    end

    describe 'gender' do
      it 'defines the correct gender values' do
        expect(CattleCertification.genders.keys).to contain_exactly('male', 'female')
      end
    end

    describe 'dental_chronology' do
      it 'defines the correct dental_chronology values' do
        expected_values = %w[
          milk_incisors_first_medians
          milk_second_medians
          milk_corners
          leveling_incisors
          leveling_first_medians
          leveling_second_medians
          leveling_corners
          permanent_incisors
          permanent_first_medians
          permanent_second_medians
          permanent_corners
          full_dentition
        ]
        expect(CattleCertification.dental_chronologies.keys).to contain_exactly(*expected_values)
      end
    end

    describe 'pregnancy_diagnosis_method' do
      it 'defines the correct pregnancy_diagnosis_method values' do
        expect(CattleCertification.pregnancy_diagnosis_methods.keys).to contain_exactly('palpation', 'ultrasound',
                                                                                        'blood_test')
      end
    end
  end

  describe 'validations' do
    describe 'data_taken_at_cannot_be_future' do
      it 'is valid with past date' do
        cattle_certification.data_taken_at = 1.day.ago
        expect(cattle_certification).to be_valid
      end

      it 'is valid with present date' do
        cattle_certification.data_taken_at = Time.current
        expect(cattle_certification).to be_valid
      end

      it 'is invalid with future date' do
        cattle_certification.data_taken_at = 1.day.from_now
        expect(cattle_certification).not_to be_valid
        expect(cattle_certification.errors[:data_taken_at]).to include('cannot be in the future')
      end

      it 'is valid when data_taken_at is nil' do
        cattle_certification.data_taken_at = nil
        expect(cattle_certification).to be_valid
      end
    end

    describe 'pregnancy_service_range_cannot_be_future' do
      it 'is valid with past range' do
        cattle_certification.pregnancy_service_range = 2.months.ago..1.month.ago
        expect(cattle_certification).to be_valid
      end

      it 'is valid with range ending today' do
        cattle_certification.pregnancy_service_range = 1.month.ago..Time.current
        expect(cattle_certification).to be_valid
      end

      it 'is invalid with range ending in future' do
        cattle_certification.pregnancy_service_range = 1.month.ago..1.day.from_now
        expect(cattle_certification).not_to be_valid
        expect(cattle_certification.errors[:pregnancy_service_range]).to include('cannot be in the future')
      end

      it 'is valid when pregnancy_service_range is nil' do
        cattle_certification.pregnancy_service_range = nil
        expect(cattle_certification).to be_valid
      end
    end
  end

  describe 'factory' do
    it 'creates valid cattle_certification' do
      expect(cattle_certification).to be_valid
    end

    it 'creates cattle_certification with photo attachment' do
      created_certification = create(:cattle_certification)
      expect(created_certification.photo).to be_attached
    end

    it 'attaches photo with correct content type' do
      created_certification = create(:cattle_certification)
      expect(created_certification.photo.content_type).to eq('image/png')
    end

    describe 'traits' do
      describe ':female trait' do
        subject(:female_cattle) { build(:cattle_certification, :female) }

        it 'sets gender to female' do
          expect(female_cattle.gender).to eq('female')
        end

        it 'sets pregnant to true' do
          expect(female_cattle.pregnant).to be true
        end

        it 'sets pregnancy_diagnosis_method to ultrasound' do
          expect(female_cattle.pregnancy_diagnosis_method).to eq('ultrasound')
        end
      end

      describe ':weaned_heifer trait' do
        subject(:heifer) { build(:cattle_certification, :weaned_heifer) }

        it 'sets category to weaned_heifer' do
          expect(heifer.category).to eq('weaned_heifer')
        end

        it 'sets gender to female' do
          expect(heifer.gender).to eq('female')
        end

        it 'sets estimated_weight to 220' do
          expect(heifer.estimated_weight).to eq(220)
        end
      end

      describe ':weaned_steer trait' do
        subject(:steer) { build(:cattle_certification, :weaned_steer) }

        it 'sets category to weaned_steer' do
          expect(steer.category).to eq('weaned_steer')
        end

        it 'sets gender to male' do
          expect(steer.gender).to eq('male')
        end

        it 'sets estimated_weight to 250' do
          expect(steer.estimated_weight).to eq(250)
        end
      end
    end
  end
end
