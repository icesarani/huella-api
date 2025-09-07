# frozen_string_literal: true

# == Schema Information
#
# Table name: vet_work_schedules
#
#  id             :bigint           not null, primary key
#  friday         :enum             default("none"), not null
#  monday         :enum             default("none"), not null
#  saturday       :enum             default("none"), not null
#  sunday         :enum             default("none"), not null
#  thursday       :enum             default("none"), not null
#  tuesday        :enum             default("none"), not null
#  wednesday      :enum             default("none"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  vet_profile_id :bigint           not null
#
# Indexes
#
#  index_vet_work_schedules_on_vet_profile_id  (vet_profile_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (vet_profile_id => vet_profiles.id)
#
class VetWorkSchedule < ApplicationRecord
  belongs_to :vet_profile, inverse_of: :vet_work_schedule

  # Define the enum values
  WORK_SCHEDULE_VALUES = %w[none morning afternoon both].freeze

  # Validate enum values since we're using database enums directly
  validates :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday,
            inclusion: { in: WORK_SCHEDULE_VALUES }

  # @return [Array<String>] List of valid work schedule time values
  # @example
  #   VetWorkSchedule.work_schedule_values # => ["none", "morning", "afternoon", "both"]
  def self.work_schedule_values
    WORK_SCHEDULE_VALUES
  end

  # @return [Array<Symbol>] List of days when the veterinarian works
  # @example
  #   schedule.working_days # => [:monday, :wednesday, :friday]
  def working_days
    %i[monday tuesday wednesday thursday friday saturday sunday].reject do |day|
      public_send(day) == 'none'
    end
  end

  # @param day [Symbol] Day of the week (:monday, :tuesday, etc.)
  # @return [Boolean] True if the veterinarian works on the specified day
  # @example
  #   schedule.works_on?(:monday) # => true
  #   schedule.works_on?(:sunday) # => false
  def works_on?(day)
    return false unless respond_to?(day)

    public_send(day) != 'none'
  end

  # @return [Boolean] True if the veterinarian has any work schedule set
  # @example
  #   schedule.has_any_work_time? # => true
  def any_work_time?
    working_days.any?
  end

  # @return [Hash] Hash representation of the work schedule
  # @example
  #   schedule.to_schedule_hash # => { monday: 'morning', tuesday: 'both', ... }
  def to_schedule_hash
    {
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday
    }
  end
end
