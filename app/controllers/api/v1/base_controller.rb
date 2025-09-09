# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include CertificationErrors
      respond_to :json

      # Error handling
      rescue_from StandardError do |error|
        # Si el error viene de blockchain/certificación, lo tratamos como unprocessable
        if error.message.match?(/certif|blockchain|contract|signature|wallet|hash|ethereum/i)
          render_unprocessable_entity_with_message(error.message)
        else
          render_internal_server_error(error)
        end
      end
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      # Certification specific errors
      rescue_from CertificationErrors::RequestNotAssignedError, with: :render_certification_error
      rescue_from CertificationErrors::RequestAlreadyFinalizedError, with: :render_certification_error
      rescue_from CertificationErrors::VeterinarianNotAssignedError, with: :render_certification_error
      rescue_from CertificationErrors::TooManyCertificationsError, with: :render_certification_error
      rescue_from CertificationErrors::PhotoRequiredError, with: :render_certification_error

      # Blockchain/Ethereum errors (tratamos como unprocessable_entity por ser errores de certificación)
      rescue_from ArgumentError do |error|
        if error.message.include?('signature') ||
           error.message.include?('address') ||
           error.message.include?('Ethereum')
          render_unprocessable_entity_with_message(error.message)
        else
          render_bad_request(error)
        end
      end

      # @route GET /api/v1/health_check (api_v1_health_check)
      def health_check
        render json: { status: 'ok' }, status: :ok
      end

      protected

      # Ensure current user is a producer
      # @raise [ActionController::ParameterMissing] if user is not a producer
      def ensure_producer!
        return if current_user&.producer_profile

        render_forbidden(I18n.t('errors.authorization.producer_required'))
      end

      # Ensure current user is a veterinarian
      # @raise [ActionController::ParameterMissing] if user is not a veterinarian
      def ensure_veterinarian!
        return if current_user&.vet_profile

        render_forbidden(I18n.t('errors.authorization.veterinarian_required'))
      end

      private

      # Renders the error response in a standard format
      #
      # @param message [String] The error message to be displayed
      # @param code [Symbol] The error code to be used
      # @param status [Symbol] The HTTP status code to be returned
      # @param errors [hash] Optional hash of error details
      # @return [void]
      def render_error(message:, code:, status:)
        render 'api/v1/shared/error', locals: { code:, message: }, status:, formats: :json
      end

      # Render not found error
      # @param error [ActiveRecord::RecordNotFound]
      def render_not_found(error = nil)
        render_error(
          message: error&.message || I18n.t('errors.not_found'),
          code: 'not_found',
          status: :not_found
        )
      end

      # Render unprocessable entity error
      # @param error [ActiveRecord::RecordInvalid]
      def render_unprocessable_entity(error)
        render_error(
          message: error.record.errors.full_messages.join(', '),
          code: 'unprocessable_entity',
          status: :unprocessable_content
        )
      end

      # Render bad request error
      # @param error [ActionController::ParameterMissing]
      def render_bad_request(error)
        render_error(
          message: error.message,
          code: 'bad_request',
          status: :bad_request
        )
      end

      # Render forbidden error
      # @param message [String] Error message
      def render_forbidden(message)
        render_error(
          message:,
          code: 'forbidden',
          status: :forbidden
        )
      end

      # Render internal server error
      # @param error [StandardError]
      def render_internal_server_error(error)
        render_error(
          message: error.message,
          code: 'internal_server_error',
          status: :internal_server_error
        )
      end

      # Render certification specific errors as unprocessable entity
      # @param error [CertificationErrors::*]
      def render_certification_error(error)
        render_error(
          message: error.message,
          code: 'certification_error',
          status: :unprocessable_content
        )
      end

      # Render unprocessable entity error with custom message
      # @param message [String] Error message
      def render_unprocessable_entity_with_message(message)
        render_error(
          message: message,
          code: 'unprocessable_entity',
          status: :unprocessable_content
        )
      end
    end
  end
end
