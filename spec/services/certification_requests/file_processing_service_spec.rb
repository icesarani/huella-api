# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificationRequests::FileProcessingService, type: :service do
  describe '#call!' do
    let(:certification_request) { create(:certification_request) }
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/files/sample_image.png'),
        'image/png'
      )
    end

    context 'with valid uploaded file' do
      it 'creates a file upload record' do
        service = described_class.new(
          certification_request: certification_request,
          uploaded_file: uploaded_file
        )

        expect { service.call! }.to change(FileUpload, :count).by(1)
      end

      it 'attaches the file to the upload' do
        service = described_class.new(
          certification_request: certification_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.file).to be_attached
      end

      it 'processes file with AI analysis' do
        service = described_class.new(
          certification_request: certification_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.processed?).to be true
      end

      it 'sets AI analysis data' do
        service = described_class.new(
          certification_request: certification_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.ai_analyzed_age).to be_present
      end

      it 'sets different AI results based on cattle breed' do
        angus_request = create(:certification_request, cattle_breed: 'angus')
        service = described_class.new(
          certification_request: angus_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.ai_analyzed_breed).to eq('Angus')
      end
    end

    context 'when file attachment fails' do
      let(:invalid_file) do
        Rack::Test::UploadedFile.new(
          StringIO.new('invalid content'),
          'text/plain',
          original_filename: ''
        )
      end

      it 'raises an error' do
        service = described_class.new(
          certification_request: certification_request,
          uploaded_file: invalid_file
        )

        expect { service.call! }.to raise_error(StandardError)
      end
    end

    context 'with different cattle breeds' do
      it 'returns Holstein results for holstein breed' do
        holstein_request = create(:certification_request, cattle_breed: 'holstein')
        service = described_class.new(
          certification_request: holstein_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.ai_analyzed_breed).to eq('Holstein')
      end

      it 'returns Hereford results for hereford breed' do
        hereford_request = create(:certification_request, cattle_breed: 'hereford')
        service = described_class.new(
          certification_request: hereford_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.ai_analyzed_breed).to eq('Hereford')
      end

      it 'returns Mixed Breed results for unknown breed' do
        other_request = create(:certification_request, cattle_breed: 'other')
        service = described_class.new(
          certification_request: other_request,
          uploaded_file: uploaded_file
        )

        result = service.call!

        expect(result.ai_analyzed_breed).to eq('Mixed Breed')
      end
    end

    context 'when AI processing simulation fails' do
      before do
        allow_any_instance_of(FileUpload).to receive(:mark_as_processed!).and_raise(StandardError)
      end

      it 'raises a processing error' do
        service = described_class.new(
          certification_request: certification_request,
          uploaded_file: uploaded_file
        )

        expect { service.call! }.to raise_error(StandardError, /Error al procesar el archivo cargado/)
      end
    end
  end
end
