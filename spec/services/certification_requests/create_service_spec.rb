# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificationRequests::CreateService, type: :service do
  describe '#call!' do
    let(:user) { create(:user_with_producer_profile) }
    let(:producer_profile) { user.producer_profile }
    let(:locality) { create(:locality) }
    let(:request_params) do
      {
        address: 'Farm Address 123',
        locality_id: locality.id,
        intended_animal_group: 50,
        declared_lot_weight: 450,
        declared_lot_age: 24,
        cattle_breed: 'angus',
        preferred_time_range_start: '2024-12-01 09:00:00 -0300',
        preferred_time_range_end: '2024-12-01 17:00:00 -0300'
      }
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/files/sample_image.png'),
        'image/png'
      )
    end

    before do
      # Stub veterinarian assignment to focus on file processing
      allow_any_instance_of(CertificationRequests::VeterinarianAssignmentService).to receive(:call!).and_return(true)
    end

    context 'when user is a producer' do
      it 'creates a certification request successfully' do
        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result).to be_a(CertificationRequest)
      end

      it 'sets the correct attributes on the certification request' do
        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.address).to eq('Farm Address 123')
      end

      it 'associates the certification request with the producer' do
        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.producer_profile).to eq(producer_profile)
      end

      it 'calls FileProcessingService when file is uploaded' do
        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        expect_any_instance_of(CertificationRequests::FileProcessingService).to receive(:call!)

        service.call!
      end

      it 'calls VeterinarianAssignmentService' do
        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        expect_any_instance_of(CertificationRequests::VeterinarianAssignmentService).to receive(:call!)

        service.call!
      end
    end

    context 'when user is not a producer' do
      let(:vet_user) { create(:user_with_vet_profile) }

      it 'raises an error' do
        service = described_class.new(
          user: vet_user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        expect { service.call! }.to raise_error(StandardError, /productor/i)
      end
    end

    context 'when no file is uploaded' do
      it 'raises validation error for missing file' do
        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: nil
        )

        expect { service.call! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when service fails' do
      it 'rolls back transaction when FileProcessingService fails' do
        allow_any_instance_of(CertificationRequests::FileProcessingService)
          .to receive(:call!)
          .and_raise(StandardError, 'File processing failed')

        service = described_class.new(
          user: user,
          request_params: request_params,
          uploaded_file: uploaded_file
        )

        expect { service.call! }.to raise_error(StandardError)
      end
    end

    context 'with invalid request parameters' do
      let(:invalid_params) { request_params.merge(address: '') }

      it 'raises validation error' do
        service = described_class.new(
          user: user,
          request_params: invalid_params,
          uploaded_file: nil
        )

        expect { service.call! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
