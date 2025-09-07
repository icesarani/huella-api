# frozen_string_literal: true

class CreateVetWorkSchedules < ActiveRecord::Migration[8.0]
  def change
    create_enum :work_schedule_time, %w[none morning afternoon both]

    create_table :vet_work_schedules do |t|
      t.references :vet_profile, null: false, foreign_key: true, index: { unique: true }
      t.enum :monday, enum_type: :work_schedule_time, null: false, default: 'none'
      t.enum :tuesday, enum_type: :work_schedule_time, null: false, default: 'none'
      t.enum :wednesday, enum_type: :work_schedule_time, null: false, default: 'none'
      t.enum :thursday, enum_type: :work_schedule_time, null: false, default: 'none'
      t.enum :friday, enum_type: :work_schedule_time, null: false, default: 'none'
      t.enum :saturday, enum_type: :work_schedule_time, null: false, default: 'none'
      t.enum :sunday, enum_type: :work_schedule_time, null: false, default: 'none'

      t.timestamps
    end
  end
end
