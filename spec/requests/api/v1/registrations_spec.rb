# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST /api/v1/registrations' do
    context 'with valid producer profile parameters' do
      let(:valid_producer_params) do
        {
          user: {
            email: "producer#{Time.current.to_f}@example.com",
            password: 'password123',
            producer_profile_attributes: {
              name: 'Juan Pérez',
              cuig_number: "CUIG#{Time.current.to_i}",
              renspa_number: "RENSPA#{Time.current.to_i}",
              identity_card: Time.current.to_i.to_s
            }
          }
        }
      end

      before do
        post '/api/v1/registrations', params: valid_producer_params, as: :json
      end

      it 'creates a new user and returns 200 status' do
        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(200)
      end

      it 'returns the id of the new user' do
        expect(json_response).to have_key('id')
      end

      it 'returns user data directly in response' do
        expect(json_response).to have_key('id')
        expect(json_response).to have_key('email')
      end

      it 'returns JWT token in Authorization header' do
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end

      it 'creates a producer profile' do
        user = User.find(json_response['id'])
        expect(user.producer_profile).to be_present
        expect(user.vet_profile).to be_nil
      end

      it 'creates a blockchain wallet for the producer' do
        user = User.find(json_response['id'])
        expect(user.producer_profile.blockchain_wallet).to be_present
      end

      it 'signs in the user after registration' do
        expect(response.headers['Set-Cookie']).to be_present
      end
    end

    context 'with valid vet profile parameters' do
      let(:valid_vet_params) do
        {
          user: {
            email: "vet#{Time.current.to_f}@example.com",
            password: 'password123',
            vet_profile_attributes: {
              first_name: 'María',
              last_name: 'González',
              license_number: "LIC#{Time.current.to_i}",
              identity_card: (Time.current.to_i + 1000).to_s
            }
          }
        }
      end

      before do
        post '/api/v1/registrations', params: valid_vet_params, as: :json
      end

      it 'creates a new user and returns 200 status' do
        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(200)
      end

      it 'returns the id of the new user' do
        expect(json_response).to have_key('id')
      end

      it 'returns user data directly in response' do
        expect(json_response).to have_key('id')
        expect(json_response).to have_key('email')
      end

      it 'returns JWT token in Authorization header' do
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end

      it 'creates a vet profile' do
        user = User.find(json_response['id'])
        expect(user.vet_profile).to be_present
        expect(user.producer_profile).to be_nil
      end

      it 'creates a blockchain wallet for the vet' do
        user = User.find(json_response['id'])
        expect(user.vet_profile.blockchain_wallet).to be_present
      end

      it 'signs in the user after registration' do
        expect(response.headers['Set-Cookie']).to be_present
      end
    end

    context 'with valid vet profile parameters including service areas' do
      let!(:locality1) { create(:locality) }
      let!(:locality2) { create(:locality) }
      let(:valid_vet_params_with_service_areas) do
        {
          user: {
            email: "vet_with_areas#{Time.current.to_f}@example.com",
            password: 'password123',
            vet_profile_attributes: {
              first_name: 'Carlos',
              last_name: 'Rodríguez',
              license_number: "LIC#{Time.current.to_i}",
              identity_card: (Time.current.to_i + 2000).to_s,
              vet_service_areas_attributes: [
                { locality_id: locality1.id },
                { locality_id: locality2.id }
              ]
            }
          }
        }
      end

      # @example Testing vet profile registration with service areas
      #   This test verifies that a vet profile can be created with associated service areas
      #   through the nested attributes during registration.
      it 'creates vet service areas when provided in registration' do
        post '/api/v1/registrations', params: valid_vet_params_with_service_areas, as: :json

        user = User.find(json_response['id'])
        expect(user.vet_profile.vet_service_areas.count).to eq(2)
      end
    end

    context 'with valid vet profile parameters without service areas' do
      let(:valid_vet_params_without_service_areas) do
        {
          user: {
            email: "vet_no_areas#{Time.current.to_f}@example.com",
            password: 'password123',
            vet_profile_attributes: {
              first_name: 'Ana',
              last_name: 'López',
              license_number: "LIC#{Time.current.to_i + 1}",
              identity_card: (Time.current.to_i + 3000).to_s
            }
          }
        }
      end

      # @example Testing vet profile registration without service areas
      #   This test verifies that a vet profile can be created successfully
      #   even when no service areas are provided in the registration.
      it 'creates vet profile without service areas when none provided' do
        post '/api/v1/registrations', params: valid_vet_params_without_service_areas, as: :json

        user = User.find(json_response['id'])
        expect(user.vet_profile.vet_service_areas.count).to eq(0)
      end
    end

    context 'with invalid parameters' do
      context 'when no profile is provided' do
        let(:invalid_params) do
          {
            user: {
              email: 'user@example.com',
              password: 'password123'
            }
          }
        end

        before do
          post '/api/v1/registrations', params: invalid_params, as: :json
        end

        it 'returns 422 status with validation errors' do
          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
        end

        it 'returns the errors key with base error' do
          expect(json_response).to have_key('errors')
          expect(json_response['errors']).to have_key('base')
        end

        it 'doesnt create the user model' do
          expect(User.find_by(email: invalid_params[:user][:email])).to be_nil
        end
      end

      context 'when both profiles are provided' do
        let(:invalid_params) do
          {
            user: {
              email: 'bothprofiles@example.com',
              password: 'password123',
              producer_profile_attributes: {
                name: 'Juan Pérez',
                cuig_number: 'CUIG123456',
                renspa_number: 'RENSPA12345',
                identity_card: '12345678'
              },
              vet_profile_attributes: {
                first_name: 'María',
                last_name: 'González',
                license_number: 'LIC123456',
                identity_card: '87654321'
              }
            }
          }
        end

        before do
          post '/api/v1/registrations', params: invalid_params, as: :json
        end

        it 'returns 422 status with validation errors' do
          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
        end

        it 'returns the errors key with base error' do
          expect(json_response).to have_key('errors')
          expect(json_response['errors']).to have_key('base')
        end

        it 'doesnt create the user model' do
          expect(User.find_by(email: invalid_params[:user][:email])).to be_nil
        end
      end

      context 'when producer profile attributes are invalid' do
        let(:invalid_params) do
          {
            user: {
              email: 'producer@example.com',
              password: 'password123',
              producer_profile_attributes: {
                name: '',
                cuig_number: '',
                renspa_number: 'RENSPA12345',
                identity_card: '12345678'
              }
            }
          }
        end

        before do
          post '/api/v1/registrations', params: invalid_params, as: :json
        end

        it 'returns 422 status with validation errors' do
          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
        end

        it 'returns validation errors for producer profile fields' do
          expect(json_response).to have_key('errors')
        end

        it 'doesnt create the user model' do
          expect(User.find_by(email: invalid_params[:user][:email])).to be_nil
        end
      end

      context 'when vet profile attributes are invalid' do
        let(:invalid_params) do
          {
            user: {
              email: 'vet@example.com',
              password: 'password123',
              vet_profile_attributes: {
                first_name: '',
                last_name: '',
                license_number: 'LIC123456',
                identity_card: '87654321'
              }
            }
          }
        end

        before do
          post '/api/v1/registrations', params: invalid_params, as: :json
        end

        it 'returns 422 status with validation errors' do
          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
        end

        it 'returns validation errors for vet profile fields' do
          expect(json_response).to have_key('errors')
        end

        it 'doesnt create the user model' do
          expect(User.find_by(email: invalid_params[:user][:email])).to be_nil
        end
      end

      context 'when email already exists' do
        let!(:existing_user) { create(:user_with_producer_profile) }
        let(:duplicate_params) do
          {
            user: {
              email: existing_user.email,
              password: 'password123',
              producer_profile_attributes: {
                name: 'Juan Pérez',
                cuig_number: 'CUIG123456',
                renspa_number: 'RENSPA12345',
                identity_card: '12345678'
              }
            }
          }
        end

        it 'returns 422 status with validation errors' do
          expect do
            post '/api/v1/registrations', params: duplicate_params, as: :json
          end.not_to change(User, :count)

          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
          expect(json_response).to have_key('errors')
        end
      end

      context 'when duplicated identity cards' do
        let(:duplicate_identity_card) { "DUP#{Time.current.to_i}" }
        let!(:existing_producer) do
          create(:user_with_producer_profile).producer_profile.tap do |p|
            p.update!(identity_card: duplicate_identity_card)
          end
        end
        let(:duplicate_params) do
          {
            user: {
              email: "newproducer#{Time.current.to_f}@example.com",
              password: 'password123',
              producer_profile_attributes: {
                name: 'Juan Pérez',
                cuig_number: "CUIG#{Time.current.to_i + 999}",
                renspa_number: "RENSPA#{Time.current.to_i + 999}",
                identity_card: duplicate_identity_card
              }
            }
          }
        end

        it 'returns 422 status with validation errors' do
          expect do
            post '/api/v1/registrations', params: duplicate_params, as: :json
          end.not_to change(User, :count)

          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
          expect(json_response).to have_key('errors')
        end
      end
    end
  end
end
