# frozen_string_literal: true

module CertificationRequests
  class VeterinarianAssignmentService < ApplicationService
    # Assigns an available veterinarian to a certification request
    #
    # @param certification_request [CertificationRequest] The certification request to assign
    # @return [CertificationRequest] The updated certification request with assigned veterinarian
    # @raise [StandardError] If no veterinarian is available
    def initialize(certification_request:)
      @certification_request = certification_request
      super
    end

    # Finds and assigns an available veterinarian
    # @return [CertificationRequest] The updated certification request
    # @raise [StandardError] If no veterinarian available
    def call!
      find_available_veterinarian!
      assign_veterinarian_and_schedule!
      @certification_request
    end

    private

    attr_reader :certification_request, :assigned_veterinarian, :scheduled_date, :scheduled_time

    # Finds an available veterinarian based on locality and schedule
    # @raise [StandardError] If no veterinarian available
    def find_available_veterinarian!
      @assigned_veterinarian = available_veterinarians.first

      return unless @assigned_veterinarian

      determine_schedule!
    end

    # Gets veterinarians who serve the certification request locality
    # @return [ActiveRecord::Relation<VetProfile>] Available veterinarians
    def available_veterinarians
      VetProfile.joins(:vet_service_areas, :vet_work_schedule)
                .where(vet_service_areas: { locality: certification_request.locality })
                .where.not(vet_work_schedules: { id: nil })
                .includes(:vet_work_schedule)
                .select { |vet| vet_available?(vet) }
    end

    # Checks if a veterinarian is available for the preferred time range
    # @param vet_profile [VetProfile] The veterinarian profile
    # @return [Boolean] True if veterinarian is available
    def vet_available?(vet_profile) # rubocop:disable Metrics/AbcSize
      return false unless vet_profile.vet_work_schedule.any_work_time?

      time_range = certification_request.preferred_time_range
      return false unless time_range

      # Check each day in the preferred time range
      (time_range.begin.to_date..time_range.end.to_date).any? do |date|
        day_symbol = date.strftime('%A').downcase.to_sym
        schedule = vet_profile.vet_work_schedule

        next false unless schedule.works_on?(day_symbol)
        next false if vet_has_conflict?(vet_profile, date)

        # Check if the time of day matches the schedule
        time_matches_schedule?(schedule, day_symbol, time_range)
      end
    end

    # Checks if veterinarian has conflicting appointments on the given date
    # @param vet_profile [VetProfile] The veterinarian profile
    # @param date [Date] The date to check
    # @return [Boolean] True if there's a conflict
    def vet_has_conflict?(vet_profile, date)
      CertificationRequest.where(
        vet_profile: vet_profile,
        scheduled_date: date,
        status: [CertificationRequest.statuses[:assigned], CertificationRequest.statuses[:created]]
      ).exists?
    end

    # Checks if the preferred time matches the veterinarian's schedule
    # @param schedule [VetWorkSchedule] The work schedule
    # @param day_symbol [Symbol] Day of the week
    # @param time_range [Range] The preferred time range
    # @return [Boolean] True if time matches schedule
    def time_matches_schedule?(schedule, day_symbol, time_range) # rubocop:disable Metrics/MethodLength
      work_time = schedule.public_send(day_symbol)
      return false if work_time == 'none'
      return true if work_time == 'both'

      # Check if preferred time overlaps with work schedule
      hour = time_range.begin.hour
      case work_time
      when 'morning'
        hour < 12
      when 'afternoon'
        hour >= 12
      else
        false
      end
    end

    # Determines the best schedule for the assignment
    def determine_schedule! # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      time_range = certification_request.preferred_time_range
      schedule = @assigned_veterinarian.vet_work_schedule

      # Find the first available date within the preferred range
      (time_range.begin.to_date..time_range.end.to_date).each do |date|
        day_symbol = date.strftime('%A').downcase.to_sym

        next unless schedule.works_on?(day_symbol)
        next if vet_has_conflict?(@assigned_veterinarian, date)
        next unless time_matches_schedule?(schedule, day_symbol, time_range)

        @scheduled_date = date
        @scheduled_time = determine_time_slot(schedule, day_symbol, time_range)
        return # rubocop:disable Lint/NonLocalExitFromIterator
      end

      raise StandardError, I18n.t('errors.certification_request.veterinarian_assignment_failed')
    end

    # Determines the specific time slot (morning/afternoon)
    # @param schedule [VetWorkSchedule] The work schedule
    # @param day_symbol [Symbol] Day of the week
    # @param time_range [Range] The preferred time range
    # @return [String] 'morning' or 'afternoon'
    def determine_time_slot(schedule, day_symbol, time_range)
      work_time = schedule.public_send(day_symbol)
      return 'morning' if work_time == 'morning'
      return 'afternoon' if work_time == 'afternoon'

      # If 'both', choose based on preferred time
      hour = time_range.begin.hour
      hour < 12 ? 'morning' : 'afternoon'
    end

    # Assigns the veterinarian and updates the certification request
    # @raise [ActiveRecord::RecordInvalid] If update fails
    def assign_veterinarian_and_schedule!
      certification_request.update!(
        vet_profile: @assigned_veterinarian,
        scheduled_date: @scheduled_date,
        scheduled_time: @scheduled_time,
        status: CertificationRequest.statuses[:assigned]
      )
    end
  end
end
