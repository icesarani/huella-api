# frozen_string_literal: true

class CreateCattleCertifications < ActiveRecord::Migration[8.0]
  def change # rubocop:disable Metrics/AbcSize
    create_enum :cattle_category, %w[unweaned_calf weaned_heifer weaned_steer]
    create_enum :gender, %w[male female]
    create_enum :dental_chronology, %w[
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
    create_enum :pregnancy_diagnosis_method, %w[palpation ultrasound blood_test]

    create_table :cattle_certifications do |t|
      t.references :certified_lot, null: false, foreign_key: true
      t.string :cuig_code
      t.string :alternative_code
      t.enum :gender, enum_type: :gender, null: false
      t.enum :category, enum_type: :cattle_category, null: false
      t.enum :dental_chronology, enum_type: :dental_chronology
      t.integer :estimated_weight
      t.boolean :pregnant
      t.enum :pregnancy_diagnosis_method, enum_type: :pregnancy_diagnosis_method
      t.tstzrange :pregnancy_service_range
      t.integer :corporal_condition
      t.string :brucellosis_diagnosis
      t.string :comments
      t.jsonb :geolocation_points, default: { lat: 0, lng: 0 }
      t.datetime :data_taken_at

      t.timestamps
    end
  end
end
