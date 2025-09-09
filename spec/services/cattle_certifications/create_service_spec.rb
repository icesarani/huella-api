# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CattleCertifications::CreateService, type: :service do
  subject(:service) do
    described_class.new(
      certified_lot: certified_lot,
      certification_params: certification_params
    )
  end

  let(:certified_lot) { create(:certified_lot) }
  let(:photo_file) { fixture_file_upload('spec/fixtures/files/sample_image.png', 'image/png') }

  let(:certification_params) do
    {
      cuig_code: 'CUIG123',
      gender: :male,
      category: :unweaned_calf,
      photo: photo_file,
      data_taken_at: 1.day.ago
    }
  end

  describe '#call' do
    context 'when all parameters are valid' do
      it 'creates a cattle certification' do
        expect { service.call }.to change(CattleCertification, :count).by(1)
      end

      it 'returns the cattle certification' do
        result = service.call
        expect(result).to be_a(CattleCertification)
      end

      it 'associates with certified lot' do
        result = service.call
        expect(result.certified_lot).to eq(certified_lot)
      end

      it 'attaches photo' do
        result = service.call
        expect(result.photo).to be_attached
      end
    end

    context 'when photo is missing' do
      let(:certification_params) do
        {
          cuig_code: 'CUIG123',
          gender: :male,
          category: :unweaned_calf,
          data_taken_at: 1.day.ago
        }
      end

      it 'raise CertificationErrors::PhotoRequiredError' do
        expect { service.call }.to raise_error(CertificationErrors::PhotoRequiredError, /Se requiere foto/)
      end
    end
  end

  describe '#call!' do
    context 'when photo is missing' do
      let(:certification_params) do
        {
          cuig_code: 'CUIG123',
          gender: :male,
          category: :unweaned_calf,
          data_taken_at: 1.day.ago
        }
      end

      it 'raises StandardError' do
        expect { service.call! }.to raise_error(StandardError)
      end
    end
  end
end
