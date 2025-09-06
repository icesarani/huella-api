# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST /api/v1/registrations' do
    context 'with valid producer profile parameters' do
      let(:valid_producer_params) do
        {
          user: {
            email: 'producer@example.com',
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

      before do
        post '/api/v1/registrations', params: valid_producer_params, as: :json
      end

      it 'creates a new user and returns 200 status' do
        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(200)
      end

      it 'returns the id of the new user' do
        expect(json_response).to have_key('id')
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
            email: 'vet@example.com',
            password: 'password123',
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
        post '/api/v1/registrations', params: valid_vet_params, as: :json
      end

      it 'creates a new user and returns 200 status' do
        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(200)
      end

      it 'returns the id of the new user' do
        expect(json_response).to have_key('id')
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
        let!(:existing_producer) do
          create(:user_with_producer_profile).producer_profile.tap do |p|
            p.update!(identity_card: '12345678')
          end
        end
        let(:duplicate_params) do
          {
            user: {
              email: 'newproducer@example.com',
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
    end
  end
end
