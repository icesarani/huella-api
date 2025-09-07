# frozen_string_literal: true

# == Schema Information
#
# Table name: file_uploads
#
#  id                       :bigint           not null, primary key
#  ai_analyzed_age          :string
#  ai_analyzed_breed        :string
#  ai_analyzed_weight       :string
#  processed_at             :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  certification_request_id :bigint           not null
#
# Indexes
#
#  index_file_uploads_on_certification_request_id  (certification_request_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (certification_request_id => certification_requests.id)
#
require 'rails_helper'

RSpec.describe FileUpload, type: :model do
  describe 'associations' do
    it { should belong_to(:certification_request).inverse_of(:file_upload) }
  end

  describe 'validations' do
    subject { build(:file_upload) }

    it { should validate_presence_of(:file) }
    it { should validate_presence_of(:certification_request) }
    it { should validate_uniqueness_of(:certification_request) }
  end

  describe 'ActiveStorage attachments' do
    it { should have_one_attached(:file) }
  end

  describe 'scopes' do
    let!(:processed_upload) { create(:file_upload, :processed) }
    let!(:unprocessed_upload) { create(:file_upload, :unprocessed) }

    describe '.processed' do
      it 'returns only processed uploads' do
        expect(FileUpload.processed).to include(processed_upload)
        expect(FileUpload.processed).not_to include(unprocessed_upload)
      end
    end

    describe '.unprocessed' do
      it 'returns only unprocessed uploads' do
        expect(FileUpload.unprocessed).to include(unprocessed_upload)
        expect(FileUpload.unprocessed).not_to include(processed_upload)
      end
    end
  end

  describe '#processed?' do
    context 'when processed_at is present' do
      it 'returns true' do
        file_upload = build(:file_upload, processed_at: Time.current)
        expect(file_upload.processed?).to be true
      end
    end

    context 'when processed_at is nil' do
      it 'returns false' do
        file_upload = build(:file_upload, processed_at: nil)
        expect(file_upload.processed?).to be false
      end
    end
  end

  describe '#analysis_complete?' do
    context 'when all AI analysis fields are present' do
      it 'returns true' do
        file_upload = build(:file_upload, :processed)
        expect(file_upload.analysis_complete?).to be true
      end
    end

    context 'when some AI analysis fields are missing' do
      it 'returns false' do
        file_upload = build(:file_upload, ai_analyzed_age: nil)
        expect(file_upload.analysis_complete?).to be false
      end
    end
  end

  describe '#mark_as_processed!' do
    let(:file_upload) { create(:file_upload, :unprocessed) }
    let(:age) { '2.5 years' }
    let(:weight) { '500 kg' }
    let(:breed) { 'Holstein' }

    it 'updates AI analysis fields and processed_at timestamp' do
      file_upload.mark_as_processed!(age: age, weight: weight, breed: breed)

      expect(file_upload.ai_analyzed_age).to eq(age)
      expect(file_upload.ai_analyzed_weight).to eq(weight)
      expect(file_upload.ai_analyzed_breed).to eq(breed)
      expect(file_upload.processed_at).to be_present
    end

    it 'marks the upload as processed' do
      file_upload.mark_as_processed!(age: age, weight: weight, breed: breed)

      expect(file_upload.processed?).to be true
      expect(file_upload.analysis_complete?).to be true
    end
  end

  describe 'file format validations' do
    let(:certification_request) { create(:certification_request) }

    context 'with acceptable file types' do
      %w[image/jpeg image/jpg image/png].each do |content_type|
        it "accepts #{content_type} files" do
          file_upload = build(:file_upload, certification_request: certification_request)
          file_upload.file.attach(
            io: StringIO.new('fake content'),
            filename: "test.#{content_type.split('/').last}",
            content_type: content_type
          )

          expect(file_upload).to be_valid
        end
      end
    end

    context 'with unacceptable file types' do
      it 'rejects files with invalid content types' do
        file_upload = build(:file_upload, certification_request: certification_request)
        file_upload.file.attach(
          io: StringIO.new('fake content'),
          filename: 'test.txt',
          content_type: 'text/plain'
        )

        expect(file_upload).not_to be_valid
        expect(file_upload.errors[:file]).to include('must be a JPEG or PNG image file')
      end
    end
  end

  describe 'file size validations' do
    let(:certification_request) { create(:certification_request) }

    context 'when file is within size limit' do
      it 'accepts files under 10MB' do
        file_upload = build(:file_upload, certification_request: certification_request)
        file_upload.file.attach(
          io: StringIO.new('x' * (5 * 1024 * 1024)), # 5MB
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )

        expect(file_upload).to be_valid
      end
    end

    context 'when file exceeds size limit' do
      it 'rejects files over 10MB' do
        file_upload = build(:file_upload, certification_request: certification_request)
        file_upload.file.attach(
          io: StringIO.new('x' * (15 * 1024 * 1024)), # 15MB
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )

        expect(file_upload).not_to be_valid
        expect(file_upload.errors[:file]).to include('must be less than 10MB')
      end
    end
  end
end
