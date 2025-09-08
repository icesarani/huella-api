

module Api
  module V1
    class ViewersController < BaseController
      # @route GET /api/v1/viewer (api_v1_viewer)
      def show
        render :show, locals: { user: current_user }, status: :ok, formats: :json
      end
    end
  end
end
