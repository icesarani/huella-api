# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Viewers', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'GET /api/v1/viewer' do
    context 'when user is not authenticated' do
      it 'returns 401 status and matches openapi spec' do
        get '/api/v1/viewer', as: :json

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/viewer').with_http_status(401)
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in user
      end

      it 'returns 200 status and matches openapi spec' do
        get '/api/v1/viewer', as: :json

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/viewer').with_http_status(200)
      end

      it 'returns user data directly in response' do
        get '/api/v1/viewer', as: :json

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('id')
        expect(json_response).to have_key('email')
      end
    end
  end
end
