# frozen_string_literal: true

module CertifiedLots
  class CreateService < ApplicationService
    include CertificationErrors
    # Creates a new certified lot with cattle certifications
    #
    # @param certification_request [CertificationRequest] The certification request
    # @param vet_user [User] The veterinarian user performing certification
    # @param certifications_params [Array<Hash>] Array of cattle certification parameters
    # @return [CertifiedLot] The created certified lot with cattle certifications
    # @raise [ActiveRecord::RecordInvalid] If validation fails
    # @raise [StandardError] If any validation fails
    def initialize(certification_request:, vet_user:, certifications_params:)
      @certification_request = certification_request
      @vet_user = vet_user
      @certifications_params = certifications_params
      super
    end

    # Executes the certified lot creation process
    # @return [CertifiedLot, nil] The created certified lot or nil if validation fails
    def call
      validate_request!
      return nil if @error_message

      validate_veterinarian!
      return nil if @error_message

      validate_certifications_count!
      return nil if @error_message

      ActiveRecord::Base.transaction do
        create_certified_lot!
      end
    end

    # Version that raises exceptions for controller use
    # @return [CertifiedLot] The created certified lot
    # @raise [CertificationErrors::*] If any validation fails
    def call!
      validate_request!
      validate_veterinarian!
      validate_certifications_count!

      ActiveRecord::Base.transaction do
        certified_lot = create_certified_lot!

        # Generar certificaciones blockchain para cada cattle_certification
        certified_lot.cattle_certifications.each do |cattle_certification|
          CertificationDocuments::CreateService.new(
            cattle_certification: cattle_certification
          ).call!
        end

        certified_lot
      end
    end

    private

    attr_reader :certification_request, :vet_user, :certifications_params

    # Creates the certified lot and its cattle certifications
    # @return [CertifiedLot] The created certified lot
    def create_certified_lot!
      certified_lot = CertifiedLot.create!(certification_request: certification_request)

      certifications_params.each do |cert_params|
        CattleCertifications::CreateService.new(
          certified_lot: certified_lot,
          certification_params: cert_params
        ).call!
      end

      certified_lot.reload
    end

    # Validates the certification request is in correct state
    # @raise [CertificationErrors::*] If request is not valid for certification
    def validate_request!
      unless certification_request.status == 'assigned'
        raise RequestNotAssignedError, I18n.t('errors.certification.request_not_assigned')
      end

      return unless %w[executed canceled rejected].include?(certification_request.status)

      raise RequestAlreadyFinalizedError, I18n.t('errors.certification.request_already_finalized')
    end

    # Validates the veterinarian is assigned to this request
    # @raise [CertificationErrors::*] If veterinarian is not assigned
    def validate_veterinarian!
      unless vet_user&.vet_profile
        raise VeterinarianNotAssignedError, I18n.t('errors.authorization.veterinarian_required')
      end

      return if certification_request.vet_profile_id == vet_user.vet_profile.id

      raise VeterinarianNotAssignedError, I18n.t('errors.certification.veterinarian_not_assigned')
    end

    # Validates the number of certifications doesn't exceed intended animal group
    # @raise [CertificationErrors::TooManyCertificationsError] If too many certifications provided
    def validate_certifications_count!
      return if certifications_params.size <= certification_request.intended_animal_group

      raise TooManyCertificationsError, I18n.t(
        'errors.certification.too_many_certifications',
        provided: certifications_params.size,
        expected: certification_request.intended_animal_group
      )
    end
  end
end
