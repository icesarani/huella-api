# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CertifiedLots', type: :request do
  describe 'GET /api/v1/certified_lots' do
    before do
      # Clean up any existing data to avoid conflicts with seeds
      CertifiedLot.destroy_all
      CertificationRequest.destroy_all
    end

    let(:user) { create(:user_with_producer_profile) }
    let(:vet_user) { create(:user_with_vet_profile) }
    let!(:locality) { create(:locality) }

    let!(:certification_request) do
      create(:certification_request, :executed,
             producer_profile: user.producer_profile,
             locality: locality,
             vet_profile: vet_user.vet_profile)
    end

    let!(:certified_lot) do
      create(:certified_lot, certification_request: certification_request)
    end

    let!(:cattle_certifications) do
      create_list(:cattle_certification, 3, certified_lot: certified_lot)
    end

    let!(:another_certified_lot) do
      another_request = create(:certification_request, :executed,
                               producer_profile: create(:producer_profile),
                               locality: locality,
                               vet_profile: vet_user.vet_profile)
      create(:certified_lot, certification_request: another_request)
    end

    context 'when accessing without authentication' do
      it 'returns 200 status and matches openapi spec' do
        get '/api/v1/certified_lots', as: :json

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certified_lots').with_http_status(200)
      end

      it 'returns all certified lots' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        cert_lot_ids = json_response.map { |lot| lot['id'] }
        expect(cert_lot_ids).to include(certified_lot.id, another_certified_lot.id)
        expect(cert_lot_ids.size).to eq(2)
      end

      it 'includes certification request information' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        target_lot = json_response.find { |lot| lot['id'] == certified_lot.id }

        expect(target_lot).to have_key('certification_request')
        expect(target_lot['certification_request']).to include(
          'id' => certification_request.id,
          'address' => certification_request.address,
          'intended_animal_group' => certification_request.intended_animal_group,
          'declared_lot_weight' => certification_request.declared_lot_weight,
          'declared_lot_age' => certification_request.declared_lot_age,
          'cattle_breed' => certification_request.cattle_breed,
          'status' => certification_request.status
        )
      end

      it 'includes cattle certifications' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        target_lot = json_response.find { |lot| lot['id'] == certified_lot.id }

        expect(target_lot).to have_key('cattle_certifications')
        expect(target_lot['cattle_certifications'].size).to eq(3)
        expect(target_lot['cattle_certifications'].first).to include(
          'id',
          'cuig_code',
          'alternative_code',
          'gender',
          'category',
          'dental_chronology',
          'estimated_weight'
        )
      end

      it 'includes nested producer profile information' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        target_lot = json_response.find { |lot| lot['id'] == certified_lot.id }

        expect(target_lot['certification_request']).to have_key('producer_profile')
        expect(target_lot['certification_request']['producer_profile']).to include(
          'id' => user.producer_profile.id,
          'name' => user.producer_profile.name,
          'cuig_number' => user.producer_profile.cuig_number,
          'renspa_number' => user.producer_profile.renspa_number
        )
      end

      it 'includes nested vet profile information' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        target_lot = json_response.find { |lot| lot['id'] == certified_lot.id }

        expect(target_lot['certification_request']).to have_key('vet_profile')
        expect(target_lot['certification_request']['vet_profile']).to include(
          'id' => vet_user.vet_profile.id,
          'first_name' => vet_user.vet_profile.first_name,
          'last_name' => vet_user.vet_profile.last_name,
          'license_number' => vet_user.vet_profile.license_number
        )
      end

      it 'includes locality information' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        target_lot = json_response.find { |lot| lot['id'] == certified_lot.id }

        expect(target_lot['certification_request']).to have_key('locality')
        expect(target_lot['certification_request']['locality']).to include(
          'id' => locality.id,
          'name' => locality.name
        )
      end
    end

    context 'when certified lot has no cattle certifications' do
      let!(:empty_certified_lot) do
        request = create(:certification_request, :executed,
                         producer_profile: create(:producer_profile),
                         locality: locality,
                         vet_profile: vet_user.vet_profile)
        create(:certified_lot, certification_request: request)
      end

      it 'returns empty array for cattle_certifications' do
        get '/api/v1/certified_lots', as: :json

        json_response = JSON.parse(response.body)
        empty_lot = json_response.find { |lot| lot['id'] == empty_certified_lot.id }

        expect(empty_lot['cattle_certifications']).to eq([])
      end
    end
  end
end
