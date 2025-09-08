# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CertificationRequests', type: :request do
  describe 'POST /api/v1/certification_requests' do
    let(:user) { create(:user_with_producer_profile) }
    let(:locality) { create(:locality) }
    let!(:vet_profile) { create(:vet_profile) }
    let!(:vet_service_area) { create(:vet_service_area, vet_profile: vet_profile, locality: locality) }
    let!(:vet_work_schedule) { create(:vet_work_schedule, vet_profile: vet_profile, monday: 'both') }

    before do
      sign_in user
    end

    let(:file) do
      fixture_file_upload('spec/fixtures/files/sample_image.png', 'image/png')
    end

    let(:valid_params) do
      {
        certification_request: {
          address: 'Farm Address 123',
          locality_id: locality.id,
          intended_animal_group: 50,
          declared_lot_weight: 450,
          declared_lot_age: 24,
          cattle_breed: 'angus',
          preferred_time_range_start: '2024-12-02 09:00:00 -0300',
          preferred_time_range_end: '2024-12-02 17:00:00 -0300',
          file: file
        }
      }
    end

    context 'when user is authenticated and is a producer' do
      it 'creates a new certification request' do
        expect do
          post '/api/v1/certification_requests', params: valid_params, as: :multipart
        end.to change(CertificationRequest, :count).by(1)
      end

      it 'returns created status and matches OpenAPI schema' do
        post '/api/v1/certification_requests', params: valid_params, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(201)
      end

      it 'creates file upload and validates response schema' do
        expect do
          post '/api/v1/certification_requests', params: valid_params, as: :multipart
        end.to change(FileUpload, :count).by(1)

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(201)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'returns unauthorized status' do
        post '/api/v1/certification_requests', params: valid_params, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(401)
      end
    end

    context 'when user is not a producer' do
      let(:vet_user) { create(:user_with_vet_profile) }

      before do
        sign_out user
        sign_in vet_user
      end

      it 'returns forbidden status and matches OpenAPI schema' do
        post '/api/v1/certification_requests', params: valid_params, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(403)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          certification_request: {
            address: '',
            locality_id: nil,
            cattle_breed: 'invalid_breed'
          }
        }
      end

      it 'returns unprocessable entity status and matches OpenAPI schema' do
        post '/api/v1/certification_requests', params: invalid_params, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(422)
      end

      it 'does not create certification request' do
        expect do
          post '/api/v1/certification_requests', params: invalid_params, as: :multipart
        end.not_to change(CertificationRequest, :count)
      end
    end

    context 'when no veterinarian is available' do
      let(:remote_locality) { create(:locality) }
      let(:params_with_remote_locality) do
        valid_params.deep_merge(
          certification_request: { locality_id: remote_locality.id }
        )
      end

      it 'creates certification request with null veterinarian and returns 201' do
        post '/api/v1/certification_requests', params: params_with_remote_locality, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(201)
      end

      it 'creates certification request with null veterinarian' do
        post '/api/v1/certification_requests', params: params_with_remote_locality, as: :multipart

        expect(response.parsed_body['certification_request']['vet_profile']).to be_nil
      end
    end

    context 'when file upload is missing' do
      let(:user) { create(:user_with_producer_profile) }
      let(:locality) { create(:locality) }
      let(:params_without_file) do
        {
          certification_request: {
            address: 'Farm Address 123',
            locality_id: locality.id,
            intended_animal_group: 50,
            declared_lot_weight: 450,
            declared_lot_age: 24,
            cattle_breed: 'angus',
            preferred_time_range_start: '2024-12-02 09:00:00 -0300',
            preferred_time_range_end: '2024-12-02 17:00:00 -0300'
          }
        }
      end

      before do
        sign_in user
      end

      it 'returns unprocessable entity status and matches OpenAPI schema' do
        post '/api/v1/certification_requests', params: params_without_file, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(422)
      end

      it 'does not create certification request' do
        expect do
          post '/api/v1/certification_requests', params: params_without_file, as: :multipart
        end.not_to change(CertificationRequest, :count)
      end
    end

    context 'with missing required parameters' do
      let(:incomplete_params) do
        {
          certification_request: {
            address: 'Farm Address'
          }
        }
      end

      it 'returns unprocessable entity status and matches OpenAPI schema' do
        post '/api/v1/certification_requests', params: incomplete_params, as: :multipart

        expect(response).to match_openapi_doc($api_docs, path: '/api/v1/certification_requests').with_http_status(422)
      end
    end
  end

  describe 'POST /api/v1/certification_requests/:id/certify' do
    let(:vet_user) { create(:user_with_vet_profile) }
    let(:certification_request) { create(:certification_request, :assigned, vet_profile: vet_user.vet_profile) }
    let(:photo_file) { fixture_file_upload('spec/fixtures/files/sample_image.png', 'image/png') }

    let(:valid_certify_params) do
      {
        certifications: {
          '0' => {
            cuig_code: 'CUIG123',
            gender: 'male',
            category: 'unweaned_calf',
            photo: photo_file,
            estimated_weight: 150,
            data_taken_at: 1.day.ago.iso8601
          },
          '1' => {
            cuig_code: 'CUIG456',
            gender: 'female',
            category: 'weaned_heifer',
            photo: photo_file,
            estimated_weight: 220,
            data_taken_at: 1.day.ago.iso8601
          }
        }
      }
    end

    before do
      sign_in vet_user
    end

    context 'when user is authenticated veterinarian assigned to request' do
      it 'creates a certified lot' do
        expect do
          post "/api/v1/certification_requests/#{certification_request.id}/certify",
               params: valid_certify_params, as: :multipart
        end.to change(CertifiedLot, :count).by(1)
      end

      it 'creates cattle certifications' do
        expect do
          post "/api/v1/certification_requests/#{certification_request.id}/certify",
               params: valid_certify_params, as: :multipart
        end.to change(CattleCertification, :count).by(2)
      end

      it 'returns created status' do
        post "/api/v1/certification_requests/#{certification_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:created)
      end

      it 'returns certification request with certified lot and cattle certifications' do
        post "/api/v1/certification_requests/#{certification_request.id}/certify",
             params: valid_certify_params, as: :multipart

        response_data = response.parsed_body
        expect(response_data['certification_request']).to be_present
        expect(response_data['certification_request']['certified_lot']).to be_present
        expect(response_data['certification_request']['certified_lot']['cattle_certifications']).to be_an(Array)
        expect(response_data['certification_request']['certified_lot']['cattle_certifications'].size).to eq(2)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out vet_user }

      it 'returns unauthorized status' do
        post "/api/v1/certification_requests/#{certification_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is not a veterinarian' do
      let(:producer_user) { create(:user_with_producer_profile) }

      before do
        sign_out vet_user
        sign_in producer_user
      end

      it 'returns forbidden status' do
        post "/api/v1/certification_requests/#{certification_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when veterinarian is not assigned to request' do
      let(:other_vet) { create(:user_with_vet_profile) }

      before do
        sign_out vet_user
        sign_in other_vet
      end

      it 'returns unprocessable entity status' do
        post "/api/v1/certification_requests/#{certification_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create certified lot' do
        expect do
          post "/api/v1/certification_requests/#{certification_request.id}/certify",
               params: valid_certify_params, as: :multipart
        end.not_to change(CertifiedLot, :count)
      end
    end

    context 'when certification request does not exist' do
      it 'returns not found status' do
        post '/api/v1/certification_requests/99999/certify',
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when certification request is not assigned' do
      let(:unassigned_request) { create(:certification_request, :created) }

      it 'returns unprocessable entity status' do
        post "/api/v1/certification_requests/#{unassigned_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create certified lot' do
        expect do
          post "/api/v1/certification_requests/#{unassigned_request.id}/certify",
               params: valid_certify_params, as: :multipart
        end.not_to change(CertifiedLot, :count)
      end
    end

    context 'when certification request is already finalized' do
      let(:executed_request) { create(:certification_request, :executed, vet_profile: vet_user.vet_profile) }

      it 'returns unprocessable entity status' do
        post "/api/v1/certification_requests/#{executed_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create certified lot' do
        expect do
          post "/api/v1/certification_requests/#{executed_request.id}/certify",
               params: valid_certify_params, as: :multipart
        end.not_to change(CertifiedLot, :count)
      end
    end

    context 'when too many certifications provided' do
      let(:small_request) do
        create(:certification_request, :assigned, intended_animal_group: 1, vet_profile: vet_user.vet_profile)
      end

      it 'returns unprocessable entity status' do
        post "/api/v1/certification_requests/#{small_request.id}/certify",
             params: valid_certify_params, as: :multipart

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create certified lot' do
        expect do
          post "/api/v1/certification_requests/#{small_request.id}/certify",
               params: valid_certify_params, as: :multipart
        end.not_to change(CertifiedLot, :count)
      end
    end

    context 'when photo is missing from certification' do
      let(:params_without_photo) do
        {
          certifications: {
            '0' => {
              cuig_code: 'CUIG123',
              gender: 'male',
              category: 'unweaned_calf',
              estimated_weight: 150,
              data_taken_at: 1.day.ago.iso8601
            }
          }
        }
      end

      it 'returns unprocessable entity status' do
        post "/api/v1/certification_requests/#{certification_request.id}/certify",
             params: params_without_photo, as: :multipart

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create certified lot' do
        expect do
          post "/api/v1/certification_requests/#{certification_request.id}/certify",
               params: params_without_photo, as: :multipart
        end.not_to change(CertifiedLot, :count)
      end
    end
  end
end
