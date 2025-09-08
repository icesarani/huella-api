# frozen_string_literal: true

module CertificationRequests
  class FileProcessingService < ApplicationService
    # TODO(icesarani): Integrate with real AI service for analysis and delete mock logic.

    # Processes uploaded file and creates FileUpload with mocked AI analysis
    #
    # @param certification_request [CertificationRequest] The certification request
    # @param uploaded_file [ActionDispatch::Http::UploadedFile] The uploaded file
    # @return [FileUpload] The created file upload with AI analysis
    # @raise [ActiveRecord::RecordInvalid] If file upload creation fails
    # @raise [StandardError] If AI processing fails
    def initialize(certification_request:, uploaded_file:)
      @certification_request = certification_request
      @uploaded_file = uploaded_file
      super
    end

    # Processes the file upload and mocked AI analysis
    # @return [FileUpload] The created file upload
    # @raise [StandardError] If processing fails
    def call!
      create_file_upload!
      process_with_ai!
      @file_upload
    end

    private

    attr_reader :certification_request, :uploaded_file, :file_upload

    # Creates the file upload record and attaches the file
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    def create_file_upload!
      @file_upload = certification_request.build_file_upload

      # Handle file attachment - uploaded_file should be ActionDispatch::Http::UploadedFile
      @file_upload.file.attach(uploaded_file)
      @file_upload.save!
    end

    # Mocks AI analysis and updates file upload with results
    # In production, this would call an external AI API
    # @raise [StandardError] If AI processing fails
    def process_with_ai!
      ai_results = mock_ai_analysis

      @file_upload.mark_as_processed!(
        age: ai_results[:age],
        weight: ai_results[:weight],
        breed: ai_results[:breed]
      )
    rescue StandardError
      raise StandardError, I18n.t('errors.certification_request.file_processing_failed')
    end

    # Mocks AI analysis results
    # @return [Hash] Mocked AI analysis data
    def mock_ai_analysis # rubocop:disable Metrics/MethodLength
      # Mock different results based on cattle breed for variety
      case certification_request.cattle_breed
      when 'angus'
        { age: '2.3 years', weight: '485 kg', breed: 'Angus' }
      when 'holstein'
        { age: '3.1 years', weight: '620 kg', breed: 'Holstein' }
      when 'hereford'
        { age: '1.8 years', weight: '420 kg', breed: 'Hereford' }
      when 'brahman'
        { age: '2.7 years', weight: '510 kg', breed: 'Brahman' }
      else
        { age: '2.5 years', weight: '475 kg', breed: 'Mixed Breed' }
      end
    end
  end
end
