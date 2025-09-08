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
FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :cattle_certification do # rubocop:disable Metrics/BlockLength
    certified_lot
    cuig_code { 'CUIG123456' }
    alternative_code { 'ALT789' }
    photo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample_image.png'), 'image/png') }
    gender { :male }
    category { :unweaned_calf }
    dental_chronology { :milk_incisors_first_medians }
    estimated_weight { 150 }
    pregnant { false }
    pregnancy_diagnosis_method { :palpation }
    pregnancy_service_range { 1.month.ago..2.weeks.ago }
    corporal_condition { 3 }
    brucellosis_diagnosis { 'Negative' }
    comments { 'Healthy cattle' }
    geolocation_points { { lat: -34.6037, lng: -58.3816 } }
    data_taken_at { 1.day.ago }

    trait :female do
      gender { :female }
      pregnant { true }
      pregnancy_diagnosis_method { :ultrasound }
    end

    trait :weaned_heifer do
      category { :weaned_heifer }
      gender { :female }
      estimated_weight { 220 }
    end

    trait :weaned_steer do
      category { :weaned_steer }
      gender { :male }
      estimated_weight { 250 }
    end

    trait :with_photo do
      after(:create) do |cattle_cert|
        cattle_cert.photo.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/sample_image.png')),
          filename: 'sample_image.png',
          content_type: 'image/png'
        )
      end
    end

    trait :complete_data do
      cuig_code { 'CUIG123456' }
      alternative_code { 'ALT789' }
      gender { :male }
      category { :unweaned_calf }
      dental_chronology { :milk_incisors_first_medians }
      estimated_weight { 150 }
      pregnant { false }
      pregnancy_diagnosis_method { :palpation }
      corporal_condition { 3 }
      brucellosis_diagnosis { 'Negativo' }
      comments { 'Animal en excelente estado de salud' }
      geolocation_points { { lat: -34.6037, lng: -58.3816 } }
      data_taken_at { 1.day.ago }
    end

    trait :minimal_data do
      cuig_code { nil }
      alternative_code { nil }
      dental_chronology { nil }
      estimated_weight { nil }
      pregnant { nil }
      pregnancy_diagnosis_method { nil }
      corporal_condition { nil }
      brucellosis_diagnosis { nil }
      comments { nil }
      geolocation_points { nil }
    end
  end
end
