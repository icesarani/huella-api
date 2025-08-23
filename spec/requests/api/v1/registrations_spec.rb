# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST /api/v1/registrations' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'password123'
          }
        }
      end

      before do
        post '/api/v1/registrations', params: valid_params, as: :json
      end

      it 'creates a new user and returns 200 status' do
        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(200)
      end

      it 'returns the id of the new user' do
        expect(json_response).to have_key('id')
      end

      it 'signs in the user after registration' do
        expect(response.headers['Set-Cookie']).to be_present
      end
    end

    context 'with invalid parameters' do
      context 'when email is missing' do
        let(:invalid_params) do
          {
            user: {
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

        it 'returns the errors key' do
          expect(json_response).to have_key('errors')
        end

        it 'doesnt create the user model' do
          expect(User.find_by(email: invalid_params[:user][:email])).to be_nil
        end
      end

      context 'when email is invalid' do
        let(:invalid_params) do
          {
            user: {
              email: 'invalid-email',
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

        it 'returns the errors key' do
          expect(json_response).to have_key('errors')
        end

        it 'doesnt create the user model' do
          expect(User.find_by(email: invalid_params[:user][:email])).to be_nil
        end
      end

      context 'when password is too short' do
        let(:invalid_params) do
          {
            user: {
              email: 'user@example.com',
              password: '123'
            }
          }
        end

        it 'returns 422 status with validation errors' do
          expect do
            post '/api/v1/registrations', params: invalid_params, as: :json
          end.not_to change(User, :count)

          expect(response).to match_openapi_doc($api_docs, path: '/api/v1/registrations').with_http_status(422)
          expect(json_response).to have_key('errors')
        end
      end

      context 'when email already exists' do
        let!(:existing_user) { create(:user, email: 'existing@example.com') }
        let(:duplicate_params) do
          {
            user: {
              email: 'existing@example.com',
              password: 'password123'
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
