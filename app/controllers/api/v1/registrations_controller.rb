# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      before_action :configure_sign_up_params, only: [:create]
      respond_to :json

      # @route POST /api/v1/registrations (api_v1_registrations)
      def create
        build_resource(sign_up_params)

        resource.save

        if resource.persisted?
          sign_up(resource_name, resource)

          render :create, locals: { resource: }
        else
          render json: { errors: resource.errors }, status: :unprocessable_content
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation,
                                     producer_profile_attributes: %i[name cuig_number renspa_number identity_card],
                                     vet_profile_attributes: %i[first_name last_name license_number identity_card])
      end

      def configure_sign_up_params
        devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password password_confirmation])
      end
    end
  end
end
