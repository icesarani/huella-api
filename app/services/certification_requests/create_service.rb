# frozen_string_literal: true

module CertificationRequests
  class CreateService < ApplicationService
    # Creates a new certification request with file upload and veterinarian assignment
    #
    # @param user [User] The current user (must be a producer)
    # @param request_params [Hash] Parameters for the certification request
    # @param uploaded_file [ActionDispatch::Http::UploadedFile, nil] Optional uploaded file
    # @return [CertificationRequest] The created certification request
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    # @raise [StandardError] If any service fails
    def initialize(user:, request_params:, uploaded_file: nil)
      @user = user
      @request_params = request_params
      @uploaded_file = uploaded_file
      super
    end

    # Executes the certification request creation process
    # @return [CertificationRequest] The created certification request
    # @raise [StandardError] If any step fails
    def call!
      validate_producer!
      validate_file_upload!

      ActiveRecord::Base.transaction do
        create_certification_request!
        process_file_upload!
        assign_veterinarian!
        @certification_request
      end
    end

    private

    attr_reader :user, :request_params, :uploaded_file, :certification_request

    # Validates that the user is a producer
    # @raise [StandardError] If user is not a producer
    def validate_producer!
      raise StandardError, I18n.t('errors.authorization.producer_required') unless user.producer_profile
    end

    # Validates that a file has been uploaded
    # @raise [ActiveRecord::RecordInvalid] If no file is provided
    def validate_file_upload!
      return if @uploaded_file.present?

      # Create a temporary record to hold the validation error
      temp_record = CertificationRequest.new
      temp_record.errors.add(:file, I18n.t('errors.certification_request.file_required'))
      raise ActiveRecord::RecordInvalid, temp_record
    end

    # Creates the certification request with time range conversion
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    def create_certification_request! # rubocop:disable Metrics/AbcSize
      @certification_request = user.producer_profile.certification_requests.build(
        address: request_params[:address],
        locality_id: request_params[:locality_id],
        intended_animal_group: request_params[:intended_animal_group],
        declared_lot_weight: request_params[:declared_lot_weight],
        declared_lot_age: request_params[:declared_lot_age],
        cattle_breed: request_params[:cattle_breed],
        preferred_time_range: build_time_range
      )

      @certification_request.save!
    end

    # Builds PostgreSQL tstzrange from start and end times
    # @return [Range] Time range for preferred scheduling
    def build_time_range
      start_time = Time.parse(request_params[:preferred_time_range_start])
      end_time = Time.parse(request_params[:preferred_time_range_end])
      (start_time..end_time)
    end

    # Processes file upload using FileProcessingService
    # @raise [StandardError] If file processing fails
    def process_file_upload!
      CertificationRequests::FileProcessingService.new(
        certification_request: @certification_request,
        uploaded_file: @uploaded_file
      ).call!
    end

    # Assigns veterinarian using VeterinarianAssignmentService
    # @raise [StandardError] If no veterinarian available
    def assign_veterinarian!
      CertificationRequests::VeterinarianAssignmentService.new(
        certification_request: @certification_request
      ).call!
    end
  end
end
