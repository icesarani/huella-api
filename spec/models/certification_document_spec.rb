# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificationDocument, type: :model do
  subject { build(:certification_document) }

  describe 'associations' do
    it { should belong_to(:cattle_certification) }
    it { should belong_to(:blockchain_transaction) }
  end

  describe 'validations' do
    it { should validate_presence_of(:pdf_hash) }
    it { should validate_presence_of(:filename) }
    it { should validate_uniqueness_of(:pdf_hash) }
    it { should validate_uniqueness_of(:cattle_certification_id) }
  end

  describe 'Active Storage' do
    let(:cert_doc) { create(:certification_document_with_pdf) }

    it 'has pdf_file attached' do
      expect(cert_doc.pdf_file).to be_attached
    end

    it 'validates pdf file is attached' do
      cert_doc = build(:certification_document)
      expect(cert_doc).to be_invalid
      expect(cert_doc.errors[:pdf_file]).to include('debe estar adjunto')
    end
  end

  describe 'delegated methods' do
    let(:blockchain_tx) { create(:blockchain_transaction, :confirmed) }
    let(:cert_doc) { create(:certification_document, blockchain_transaction: blockchain_tx) }

    it 'delegates blockchain methods correctly' do
      expect(cert_doc.blockchain_confirmed?).to be true
      expect(cert_doc.blockchain_status).to eq('confirmed')
      expect(cert_doc.blockchain_transaction_hash).to eq(blockchain_tx.transaction_hash)
      expect(cert_doc.blockchain_url).to be_present
      expect(cert_doc.blockchain_network_name).to be_present
    end
  end

  describe '#blockchain_certified?' do
    context 'when blockchain transaction is confirmed' do
      let(:cert_doc) { create(:certification_document, :blockchain_confirmed) }

      it 'returns true' do
        expect(cert_doc.blockchain_certified?).to be true
      end
    end

    context 'when blockchain transaction is pending' do
      let(:cert_doc) { create(:certification_document) }

      it 'returns false' do
        expect(cert_doc.blockchain_certified?).to be false
      end
    end
  end

  describe '#pdf_size' do
    context 'when PDF is attached' do
      let(:cert_doc) { create(:certification_document_with_pdf) }

      it 'returns file size' do
        expect(cert_doc.pdf_size).to be > 0
      end
    end

    context 'when PDF is not attached' do
      let(:cert_doc) { build(:certification_document) }

      it 'returns 0' do
        expect(cert_doc.pdf_size).to eq(0)
      end
    end
  end

  describe '#pdf_content_type' do
    let(:cert_doc) { create(:certification_document_with_pdf) }

    it 'returns correct content type' do
      expect(cert_doc.pdf_content_type).to eq('application/pdf')
    end
  end

  describe '#generate_filename' do
    let(:producer_profile) { create(:producer_profile, cuig_number: 'PROD123456') }
    let(:cattle_cert) do
      create(:cattle_certification,
             cuig_code: 'CUIG987654',
             data_taken_at: Date.parse('2024-03-08'))
    end
    let(:cert_doc) { create(:certification_document) }

    before do
      allow(cattle_cert).to receive_message_chain(:certified_lot, :certification_request, :producer_profile)
        .and_return(producer_profile)
    end

    it 'generates filename with correct format' do
      filename = cert_doc.generate_filename(cattle_cert)
      expect(filename).to eq('cert_CUIG987654_20240308_PROD123456.pdf')
    end

    context 'when CUIG codes are missing' do
      before do
        allow(cattle_cert).to receive(:cuig_code).and_return(nil)
        allow(producer_profile).to receive(:cuig_number).and_return(nil)
      end

      it 'uses default values' do
        filename = cert_doc.generate_filename(cattle_cert)
        expect(filename).to include('NOCUIG')
        expect(filename).to include('NOPROD')
      end
    end
  end

  describe '.calculate_pdf_hash' do
    let(:pdf_content) { 'test pdf content' }

    it 'calculates SHA256 hash' do
      hash = CertificationDocument.calculate_pdf_hash(pdf_content)
      expected_hash = Digest::SHA256.hexdigest(pdf_content)
      expect(hash).to eq(expected_hash)
    end
  end

  describe 'pdf_hash validation' do
    let(:cert_doc) { create(:certification_document_with_pdf) }

    context 'when pdf_hash matches file content' do
      it 'is valid' do
        expect(cert_doc).to be_valid
      end
    end
  end
end
