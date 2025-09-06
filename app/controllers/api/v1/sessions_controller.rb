# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      # @route POST /api/v1/sessions (api_v1_sessions)
      def create
        self.resource = warden.authenticate!(auth_options)

        sign_in(resource_name, resource)

        render :create, locals: { user: resource }
      end

      # @route DELETE /api/v1/sessions (api_v1_sessions)
      def destroy
        sign_out(resource_name)

        head :no_content
      end
    end
  end
end
