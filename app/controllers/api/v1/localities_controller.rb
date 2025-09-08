# frozen_string_literal: true

module Api
  module V1
    class LocalitiesController < BaseController
      # @route GET /api/v1/localities (api_v1_localities)
      def index
        localities = Localities::SearchService.new.call

        render :index, locals: { localities: }, status: :ok, formats: :json
      end
    end
  end
end
