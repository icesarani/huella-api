# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      # @route POST /api/v1/sessions (api_v1_sessions)
      def create
        user = warden.authenticate!(auth_options)

        sign_in(:user, user)

        render :create, locals: { user: }
      end

      # @route DELETE /api/v1/sessions (api_v1_sessions)
      def destroy
        sign_out(resource_name)

        head :no_content
      end
    end
  end
end
