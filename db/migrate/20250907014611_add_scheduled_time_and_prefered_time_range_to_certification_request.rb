# frozen_string_literal: true

class AddScheduledTimeAndPreferedTimeRangeToCertificationRequest < ActiveRecord::Migration[8.0]
  def up
    create_enum :request_certification_scheduled_time, %w[morning afternoon]

    add_column :certification_requests, :scheduled_time, :enum,
               enum_type: :request_certification_scheduled_time
    add_column :certification_requests, :preferred_time_range, :tstzrange, null: false
    change_column :certification_requests, :scheduled_date, :date, null: true
  end

  def down
    remove_column :certification_requests, :scheduled_time
    remove_column :certification_requests, :preferred_time_range
    change_column :certification_requests, :scheduled_date, :date, null: false

    drop_enum :request_certification_scheduled_time
  end
end
