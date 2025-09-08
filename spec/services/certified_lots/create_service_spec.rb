# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertifiedLots::CreateService, type: :service do
  subject(:service) do
    described_class.new(
      certification_request: certification_request,
      vet_user: vet_user,
      certifications_params: certifications_params
    )
  end

  let(:vet_user) { create(:user_with_vet_profile) }
  let(:certification_request) { create(:certification_request, :assigned, vet_profile: vet_user.vet_profile) }
  let(:photo_file) { fixture_file_upload('spec/fixtures/files/sample_image.png', 'image/png') }

  let(:certifications_params) do
    [
      {
        cuig_code: 'CUIG123',
        gender: :male,
        category: :unweaned_calf,
        photo: photo_file,
        data_taken_at: 1.day.ago
      }
    ]
  end

  describe '#call' do
    context 'when all validations pass' do
      it 'creates a certified lot' do
        expect { service.call }.to change(CertifiedLot, :count).by(1)
      end

      it 'creates cattle certifications' do
        expect { service.call }.to change(CattleCertification, :count).by(1)
      end

      it 'returns the certified lot' do
        result = service.call
        expect(result).to be_a(CertifiedLot)
      end
    end

    context 'when certification request is not assigned' do
      let(:certification_request) { create(:certification_request, :created) }

      it 'raise CertificationErrors::RequestNotAssignedError' do
        expect { service.call }.to raise_error(CertificationErrors::RequestNotAssignedError)
      end
    end

    context 'when certification request is already finalized' do
      let(:certification_request) { create(:certification_request, :executed) }

      it 'raise CertificationErrors::RequestNotAssignedError' do
        expect { service.call }.to raise_error(CertificationErrors::RequestNotAssignedError)
      end
    end

    context 'when veterinarian is not assigned to request' do
      let(:other_vet) { create(:user_with_vet_profile) }
      let(:certification_request) { create(:certification_request, :assigned) }
      let(:vet_user) { other_vet }

      it 'raise CertificationErrors::VeterinarianNotAssignedError' do
        expect { service.call }.to raise_error(CertificationErrors::VeterinarianNotAssignedError)
      end
    end

    context 'when too many certifications provided' do
      let(:certification_request) do
        create(:certification_request, :assigned, intended_animal_group: 1, vet_profile: vet_user.vet_profile)
      end

      let(:certifications_params) do
        [
          { cuig_code: 'CUIG1', gender: :male, category: :unweaned_calf, photo: photo_file, data_taken_at: 1.day.ago },
          { cuig_code: 'CUIG2', gender: :female, category: :unweaned_calf, photo: photo_file, data_taken_at: 1.day.ago }
        ]
      end

      it 'raise CertificationErrors::TooManyCertificationsError' do
        expect { service.call }.to raise_error(CertificationErrors::TooManyCertificationsError)
      end
    end

    context 'when user is not veterinarian' do
      let(:vet_user) { create(:user_with_producer_profile) }

      it 'raise CertificationErrors::VeterinarianNotAssignedError' do
        expect { service.call }.to raise_error(CertificationErrors::VeterinarianNotAssignedError)
      end
    end
  end

  describe '#call!' do
    context 'when validation fails' do
      let(:certification_request) { create(:certification_request, :created) }

      it 'raises StandardError' do
        expect { service.call! }.to raise_error(StandardError)
      end
    end
  end
end
