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
class CattleCertification < ApplicationRecord
  has_one_attached :photo
  belongs_to :certified_lot, inverse_of: :cattle_certifications

  enum :category, {
    unweaned_calf: 'unweaned_calf',
    weaned_heifer: 'weaned_heifer',
    weaned_steer: 'weaned_steer'
  }

  enum :gender, {
    male: 'male',
    female: 'female'
  }

  enum :dental_chronology, {
    milk_incisors_first_medians: 'milk_incisors_first_medians',
    milk_second_medians: 'milk_second_medians',
    milk_corners: 'milk_corners',
    leveling_incisors: 'leveling_incisors',
    leveling_first_medians: 'leveling_first_medians',
    leveling_second_medians: 'leveling_second_medians',
    leveling_corners: 'leveling_corners',
    permanent_incisors: 'permanent_incisors',
    permanent_first_medians: 'permanent_first_medians',
    permanent_second_medians: 'permanent_second_medians',
    permanent_corners: 'permanent_corners',
    full_dentition: 'full_dentition'
  }

  enum :pregnancy_diagnosis_method, {
    palpation: 'palpation',
    ultrasound: 'ultrasound',
    blood_test: 'blood_test'
  }

  validate :data_taken_at_cannot_be_future
  validate :pregnancy_service_range_cannot_be_future

  private

  def data_taken_at_cannot_be_future
    return unless data_taken_at.present?

    errors.add(:data_taken_at, 'cannot be in the future') if data_taken_at > Time.current
  end

  def pregnancy_service_range_cannot_be_future
    return unless pregnancy_service_range.present?

    range_end = pregnancy_service_range.end
    return unless range_end

    errors.add(:pregnancy_service_range, 'cannot be in the future') if range_end > Time.current
  end
end
