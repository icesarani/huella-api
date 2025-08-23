# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      respond_to :json

      # @route GET /api/v1/health_check (api_v1_health_check)
      def health_check
        render json: { status: 'ok' }, status: :ok
      end
    end
  end
end
