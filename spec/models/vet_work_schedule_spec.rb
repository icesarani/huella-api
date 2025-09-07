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
require 'rails_helper'

RSpec.describe VetWorkSchedule, type: :model do
  describe 'associations' do
    it { should belong_to(:vet_profile).inverse_of(:vet_work_schedule) }
  end

  describe 'validations' do
    %i[monday tuesday wednesday thursday friday saturday sunday].each do |day|
      it { should validate_inclusion_of(day).in_array(VetWorkSchedule::WORK_SCHEDULE_VALUES) }
    end
  end

  describe '.work_schedule_values' do
    it 'returns the correct enum values' do
      expect(VetWorkSchedule.work_schedule_values).to eq(%w[none morning afternoon both])
    end
  end

  describe '#working_days' do
    # @example Testing working days detection
    #   This test verifies that the working_days method correctly identifies
    #   which days have work scheduled (not 'none').
    it 'returns only days with work scheduled' do
      schedule = build(:vet_work_schedule, monday: 'morning', wednesday: 'afternoon', friday: 'both')

      expect(schedule.working_days).to contain_exactly(:monday, :wednesday, :friday)
    end
  end

  describe '#works_on?' do
    # @example Testing work day checking
    #   This test verifies that the works_on? method correctly identifies
    #   whether the veterinarian works on a specific day.
    it 'returns true for working days' do
      schedule = build(:vet_work_schedule, monday: 'morning', tuesday: 'none')

      expect(schedule.works_on?(:monday)).to be true
    end

    # @example Testing non-work day checking
    #   This test verifies that the works_on? method returns false
    #   for days when the veterinarian does not work.
    it 'returns false for non-working days' do
      schedule = build(:vet_work_schedule, monday: 'morning', tuesday: 'none')

      expect(schedule.works_on?(:tuesday)).to be false
    end
  end

  describe '#any_work_time?' do
    # @example Testing work time availability detection
    #   This test verifies that the any_work_time? method correctly identifies
    #   whether the veterinarian has any work scheduled during the week.
    it 'returns true when there are working days' do
      schedule = build(:vet_work_schedule, monday: 'morning')

      expect(schedule.any_work_time?).to be true
    end

    # @example Testing no work time availability
    #   This test verifies that the any_work_time? method returns false
    #   when no work is scheduled for any day of the week.
    it 'returns false when no work is scheduled' do
      schedule = build(:vet_work_schedule)

      expect(schedule.any_work_time?).to be false
    end
  end

  describe '#to_schedule_hash' do
    # @example Testing schedule hash representation
    #   This test verifies that the to_schedule_hash method returns
    #   a hash representation of the weekly work schedule.
    it 'returns hash representation of the schedule' do
      schedule = build(:vet_work_schedule, monday: 'morning', tuesday: 'both', friday: 'afternoon')

      expected_hash = {
        monday: 'morning',
        tuesday: 'both',
        wednesday: 'none',
        thursday: 'none',
        friday: 'afternoon',
        saturday: 'none',
        sunday: 'none'
      }

      expect(schedule.to_schedule_hash).to eq(expected_hash)
    end
  end
end
