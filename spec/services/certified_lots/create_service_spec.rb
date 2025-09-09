# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertifiedLots::CreateService, type: :service do
  with_blockchain_stubs
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
  let(:sample_pdf_path) { Rails.root.join('spec/fixtures/files/sample_certificate.pdf') }
  let(:sample_pdf_content) { File.read(sample_pdf_path) }

  before do
    # Create blockchain wallets for producer and vet
    create(:blockchain_wallet, producer_profile: certification_request.producer_profile)
    create(:blockchain_wallet, vet_profile: vet_user.vet_profile)

    # Mock PDF generator to return real PDF content
    allow(Utils::CattleCertificationPdfGenerator).to receive(:call).and_return(sample_pdf_content)

    # Mock signature service with realistic signatures
    stub_signature_service
  end

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

      it 'creates blockchain certification documents' do
        expect { service.call! }.to change(CertificationDocument, :count).by(1)
      end

      it 'creates blockchain transactions' do
        expect { service.call! }.to change(BlockchainTransaction, :count).by(1)
      end

      it 'marks certification request as executed' do
        service.call!
        certification_request.reload
        expect(certification_request.status).to eq('executed')
      end

      it 'creates cattle certifications with blockchain information' do
        certified_lot = service.call!
        cattle_cert = certified_lot.cattle_certifications.first

        expect(cattle_cert.certification_document).to be_present
        expect(cattle_cert.blockchain_certified?).to be true
        expect(cattle_cert.blockchain_status).to eq('confirmed')
      end
    end

    context 'when certification request is not assigned' do
      let(:certification_request) { create(:certification_request, :created) }

      it 'raises CertificationErrors::RequestNotAssignedError' do
        expect do
          service.call
        end.to raise_error(CertificationErrors::RequestNotAssignedError) { |e| expect(e.message).to include('no está asignada a ningún veterinario') }
      end
    end

    context 'when certification request is already finalized' do
      let(:certification_request) { create(:certification_request, :executed) }

      it 'raises CertificationErrors::RequestNotAssignedError' do
        expect { service.call }.to raise_error(
          CertificationErrors::RequestNotAssignedError,
          /no está asignada a ningún veterinario/i
        )
      end
    end

    context 'when veterinarian is not assigned to request' do
      let(:other_vet) { create(:user_with_vet_profile) }
      let(:certification_request) { create(:certification_request, :assigned) }
      let(:vet_user) { other_vet }

      it 'raise CertificationErrors::VeterinarianNotAssignedError' do
        expect { service.call }.to raise_error(CertificationErrors::VeterinarianNotAssignedError,
                                               /no está asignado a esta solicitud de certificación/)
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

      it 'raises CertificationErrors::TooManyCertificationsError' do
        expect { service.call }.to raise_error(
          CertificationErrors::TooManyCertificationsError,
          /demasiadas certificaciones/i
        )
      end
    end

    context 'when user is not veterinarian' do
      let(:vet_user) { create(:user_with_producer_profile) }

      it 'raise CertificationErrors::VeterinarianNotAssignedError' do
        expect { service.call }.to raise_error(CertificationErrors::VeterinarianNotAssignedError,
                                               /Acceso restringido solo a veterinarios/)
      end
    end

    context 'when blockchain certification fails' do
      before do
        expect_certification_failure('Network connection error')
      end

      it 'does rollback and does not create anything' do
        initial_certified_lot_count = CertifiedLot.count
        initial_cattle_cert_count = CattleCertification.count
        initial_cert_doc_count = CertificationDocument.count
        initial_blockchain_tx_count = BlockchainTransaction.count

        expect { service.call! }.to raise_error(StandardError, /Network connection error/)

        # Verify rollback - nothing should be created
        expect(CertifiedLot.count).to eq(initial_certified_lot_count)
        expect(CattleCertification.count).to eq(initial_cattle_cert_count)
        expect(CertificationDocument.count).to eq(initial_cert_doc_count)
        expect(BlockchainTransaction.count).to eq(initial_blockchain_tx_count)
      end

      it 'does not mark certification request as executed' do
        expect { service.call! }.to raise_error(StandardError)

        certification_request.reload
        expect(certification_request.status).to eq('assigned')
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
