# frozen_string_literal: true

module Api
  module V1
    class CertificationRequestsController < BaseController
      before_action :ensure_producer!, only: [:create]

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

      private

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
