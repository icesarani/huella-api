# frozen_string_literal: true

module CattleCertifications
  class CreateService < ApplicationService
    include CertificationErrors
    # Creates a new cattle certification with photo attachment
    #
    # @param certified_lot [CertifiedLot] The certified lot to associate with
    # @param certification_params [Hash] Parameters for the cattle certification
    # @return [CattleCertification] The created cattle certification
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    # @raise [StandardError] If photo is missing
    def initialize(certified_lot:, certification_params:)
      @certified_lot = certified_lot
      @certification_params = certification_params
      super
    end

    # Executes the cattle certification creation process
    # @return [CattleCertification, nil] The created cattle certification or nil if validation fails
    def call
      validate_photo_presence!
      return nil if @error_message

      create_certification!
    end

    # Version that raises exceptions for controller use
    # @return [CattleCertification] The created cattle certification
    # @raise [CertificationErrors::*] If any validation fails
    def call!
      validate_photo_presence!
      create_certification!
    end

    private

    attr_reader :certified_lot, :certification_params

    # Creates the cattle certification with photo attachment
    # @return [CattleCertification] The created cattle certification
    def create_certification!
      photo_file = certification_params.delete(:photo)

      cattle_certification = CattleCertification.create!(
        certification_params.merge(certified_lot: certified_lot)
      )

      cattle_certification.photo.attach(photo_file) if photo_file
      cattle_certification
    end

    # Validates that photo is present
    # @raise [CertificationErrors::PhotoRequiredError] If photo is missing
    def validate_photo_presence!
      return if certification_params[:photo].present?

      raise PhotoRequiredError, I18n.t('errors.certification.photo_required')
    end
  end
end
