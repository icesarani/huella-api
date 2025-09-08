# frozen_string_literal: true

module Api
  module V1
    class ViewersController < BaseController
      # Devise authentication
      before_action :authenticate_user!, only: [:show]

      # @route GET /api/v1/viewer (api_v1_viewer)
      def show
        render :show, locals: { user: current_user }, status: :ok, formats: :json
      end
    end
  end
end
