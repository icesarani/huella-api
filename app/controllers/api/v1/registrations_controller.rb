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

      # @return [ActionController::Parameters] Permitted parameters for user registration
      #   Supports nested attributes for both producer and vet profiles.
      #   Vet profiles can optionally include service areas through vet_service_areas_attributes.
      #
      # @example Registration with vet profile and service areas
      #   {
      #     user: {
      #       email: "vet@example.com",
      #       password: "password123",
      #       vet_profile_attributes: {
      #         first_name: "Dr. Maria",
      #         last_name: "Garcia",
      #         license_number: "LIC123",
      #         identity_card: "12345678",
      #         vet_service_areas_attributes: [
      #           { locality_id: 1 },
      #           { locality_id: 2 }
      #         ]
      #       }
      #     }
      #   }
      #
      # @example Registration with vet profile without service areas
      #   {
      #     user: {
      #       email: "vet@example.com",
      #       password: "password123",
      #       vet_profile_attributes: {
      #         first_name: "Dr. Juan",
      #         last_name: "Perez",
      #         license_number: "LIC456",
      #         identity_card: "87654321"
      #       }
      #     }
      #   }
      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation,
                                     producer_profile_attributes: %i[name cuig_number renspa_number identity_card],
                                     vet_profile_attributes: [:first_name, :last_name, :license_number, :identity_card,
                                                              { vet_service_areas_attributes: [:locality_id] }])
      end

      def configure_sign_up_params
        devise_parameter_sanitizer.permit(:sign_up, keys: %i[email password password_confirmation])
      end
    end
  end
end
