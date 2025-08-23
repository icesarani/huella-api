# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'POST /api/v1/sessions' do
    context 'when user is not authenticated' do
      it 'returns 401 status and matches openapi spec' do
        post '/api/v1/sessions', params: { user: { email: user.email, password: 'BAD' } }, as: :json

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/sessions').with_http_status(401)
      end

      it 'doesn\'t return the Set-Cookie header' do
        post '/api/v1/sessions', params: { user: { email: user.email, password: 'BAD' } }, as: :json

        expect(response.headers['Set-Cookie']).to be nil
      end
    end

    context 'when user is authenticated' do
      it 'returns 200 status and matches openapi spec' do
        post '/api/v1/sessions', params: { user: { email: user.email, password: user.password } }, as: :json

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/sessions').with_http_status(200)
      end

      it 'returns the Set-Cookie header' do
        post '/api/v1/sessions', params: { user: { email: user.email, password: user.password } }, as: :json

        expect(response.headers['set-cookie']).to include('_huella_api_session')
      end
    end
  end
end
