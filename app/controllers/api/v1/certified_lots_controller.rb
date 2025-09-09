# frozen_string_literal: true

module Api
  module V1
    class CertifiedLotsController < ApplicationController
      # @route GET /api/v1/certified_lots (api_v1_certified_lots)
      def index
        certified_lots = CertifiedLots::SearchService.new.call

        render :index, locals: { certified_lots: }, status: :ok, as: :json
      end
    end
  end
end
