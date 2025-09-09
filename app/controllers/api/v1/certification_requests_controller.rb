# frozen_string_literal: true

module Api
  module V1
    class CertificationRequestsController < BaseController
      # Devise authentication
      before_action :authenticate_user!, only: %i[create certify]
      before_action :ensure_producer!, only: [:create]
      before_action :ensure_veterinarian!, only: [:certify]
      before_action :find_certification_request!, only: [:certify]

      # @route POST /api/v1/certification_requests (api_v1_certification_requests)
      def create
        certification_request = CertificationRequests::CreateService.new(
          user: current_user,
          request_params: certification_request_params,
          uploaded_file: params.dig(:certification_request, :file)
        ).call!

        render :create,
               locals: { certification_request: },
               status: :created, formats: :json
      end

      # @route POST /api/v1/certification_requests/:id/certify (certify_api_v1_certification_request)
      def certify
        CertifiedLots::CreateService.new(
          certification_request: @certification_request,
          vet_user: current_user,
          certifications_params: build_certifications_params
        ).call!

        # Reload to include all created data (certified_lot, cattle_certifications, blockchain docs)
        @certification_request.reload

        render :certify,
               locals: { certification_request: @certification_request },
               status: :created, formats: :json
      end

      private

      # Find certification request by ID
      # @raise [ActiveRecord::RecordNotFound] if request not found
      def find_certification_request!
        @certification_request = CertificationRequest.find_by!(id: params[:id])
      end

      # Build certifications parameters from form-data
      # @return [Array<Hash>] Array of certification parameters
      def build_certifications_params # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        certifications = []
        index = 0

        while params.dig(:certifications, index.to_s).present?
          cert_params = certification_params(index)
          if cert_params[:pregnancy_service_range_start].present? && cert_params[:pregnancy_service_range_end].present?
            cert_params[:pregnancy_service_range] =
              (cert_params[:pregnancy_service_range_start]..cert_params[:pregnancy_service_range_end])
          end
          cert_params.delete(:pregnancy_service_range_start)
          cert_params.delete(:pregnancy_service_range_end)
          certifications << cert_params if cert_params.present?
          index += 1
        end

        certifications
      end

      # Strong parameters for individual cattle certification
      # @param index [Integer] Index of the certification in form-data
      # @return [ActionController::Parameters] Permitted parameters
      def certification_params(index)
        params.require(:certifications).require(index.to_s).permit(
          :cuig_code,
          :alternative_code,
          :photo,
          :gender,
          :category,
          :dental_chronology,
          :estimated_weight,
          :pregnant,
          :pregnancy_diagnosis_method,
          :pregnancy_service_range_start,
          :pregnancy_service_range_end,
          :corporal_condition,
          :brucellosis_diagnosis,
          :comments,
          :data_taken_at,
          geolocation_points: %i[lat lng]
        )
      end

      # Strong parameters for certification request creation
      # @return [ActionController::Parameters] Permitted parameters
      def certification_request_params
        params.require(:certification_request).permit(
          :address,
          :locality_id,
          :intended_animal_group,
          :declared_lot_weight,
          :declared_lot_age,
          :cattle_breed,
          :preferred_time_range_start,
          :preferred_time_range_end,
          :file
        )
      end
    end
  end
end
