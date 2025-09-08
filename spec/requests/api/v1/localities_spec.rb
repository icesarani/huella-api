# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Localities', type: :request do
  describe 'GET /api/v1/localities' do
    let!(:locality) { FactoryBot.create(:locality, name: 'AA') }

    it 'returns 200 status and matches openapi spec' do
      get '/api/v1/localities', as: :json

      expect(response).to match_openapi_doc($api_docs, path: '/api/v1/localities').with_http_status(200)
    end

    it 'returns localities ordered by name' do
      get '/api/v1/localities', as: :json

      json_response = JSON.parse(response.body)
      expect(json_response[0]['name']).to eq(locality.name)
    end
  end
end
