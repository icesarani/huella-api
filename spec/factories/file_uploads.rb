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

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :file_upload do # rubocop:disable Metrics/BlockLength
    association :certification_request

    # Attach a sample image file for testing using in-memory file
    after(:build) do |file_upload|
      file_upload.file.attach(
        io: StringIO.new('fake jpeg content for testing'),
        filename: 'sample_image.jpg',
        content_type: 'image/jpeg'
      )
    end

    # @example Creating a file upload with PNG
    #   file_upload = create(:file_upload, :with_png)
    trait :with_png do
      after(:build) do |file_upload|
        file_upload.file.attach(
          io: StringIO.new('fake png content for testing'),
          filename: 'sample_image.png',
          content_type: 'image/png'
        )
      end
    end

    # @example Creating a processed file upload with AI analysis
    #   file_upload = create(:file_upload, :processed)
    trait :processed do
      ai_analyzed_age { '2.3 years' }
      ai_analyzed_weight { '485 kg' }
      ai_analyzed_breed { 'Angus' }
      processed_at { Time.current }
    end

    # @example Creating an unprocessed file upload
    #   file_upload = create(:file_upload, :unprocessed)
    trait :unprocessed do
      ai_analyzed_age { nil }
      ai_analyzed_weight { nil }
      ai_analyzed_breed { nil }
      processed_at { nil }
    end
  end
end
