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

# @example Creating a basic work schedule
#   vet_work_schedule = create(:vet_work_schedule)
#
# @example Creating a work schedule with specific days
#   vet_work_schedule = create(:vet_work_schedule, :weekday_mornings)
#
# @example Creating a work schedule with full time availability
#   vet_work_schedule = create(:vet_work_schedule, :full_time)
FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :vet_work_schedule do # rubocop:disable Metrics/BlockLength
    association :vet_profile

    monday { 'none' }
    tuesday { 'none' }
    wednesday { 'none' }
    thursday { 'none' }
    friday { 'none' }
    saturday { 'none' }
    sunday { 'none' }

    # @example Creating a work schedule for weekday mornings only
    #   create(:vet_work_schedule, :weekday_mornings)
    trait :weekday_mornings do
      monday { 'morning' }
      tuesday { 'morning' }
      wednesday { 'morning' }
      thursday { 'morning' }
      friday { 'morning' }
      saturday { 'none' }
      sunday { 'none' }
    end

    # @example Creating a work schedule for full-time availability
    #   create(:vet_work_schedule, :full_time)
    trait :full_time do
      monday { 'both' }
      tuesday { 'both' }
      wednesday { 'both' }
      thursday { 'both' }
      friday { 'both' }
      saturday { 'morning' }
      sunday { 'none' }
    end

    # @example Creating a work schedule for part-time afternoons
    #   create(:vet_work_schedule, :part_time_afternoons)
    trait :part_time_afternoons do
      monday { 'afternoon' }
      tuesday { 'none' }
      wednesday { 'afternoon' }
      thursday { 'none' }
      friday { 'afternoon' }
      saturday { 'none' }
      sunday { 'none' }
    end

    # @example Creating a work schedule for weekends only
    #   create(:vet_work_schedule, :weekends_only)
    trait :weekends_only do
      monday { 'none' }
      tuesday { 'none' }
      wednesday { 'none' }
      thursday { 'none' }
      friday { 'none' }
      saturday { 'both' }
      sunday { 'morning' }
    end
  end
end
