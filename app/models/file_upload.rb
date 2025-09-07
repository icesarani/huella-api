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
class FileUpload < ApplicationRecord
  belongs_to :certification_request, inverse_of: :file_upload

  has_one_attached :file

  validates :file, presence: true
  validates :certification_request, presence: true, uniqueness: true

  validate :acceptable_file_format
  validate :acceptable_file_size

  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }

  # @return [Boolean] true if the file has been processed by AI
  def processed?
    processed_at.present?
  end

  # @return [Boolean] true if AI analysis data is complete
  def analysis_complete?
    ai_analyzed_age.present? && ai_analyzed_weight.present? && ai_analyzed_breed.present?
  end

  # Mark the file as processed with AI analysis data
  # @param age [String] AI analyzed age (e.g., "2.3 years")
  # @param weight [String] AI analyzed weight (e.g., "485 kg")
  # @param breed [String] AI analyzed breed (e.g., "Angus")
  def mark_as_processed!(age:, weight:, breed:)
    update!(
      ai_analyzed_age: age,
      ai_analyzed_weight: weight,
      ai_analyzed_breed: breed,
      processed_at: Time.current
    )
  end

  private

  # Validate that the attached file is in an acceptable format
  def acceptable_file_format
    return unless file.attached?

    acceptable_types = %w[image/jpeg image/jpg image/png]
    return if acceptable_types.include?(file.content_type)

    errors.add(:file, 'must be a JPEG or PNG image file')
  end

  # Validate that the attached file is within size limits
  def acceptable_file_size
    return unless file.attached?

    max_size = 10.megabytes
    return if file.byte_size <= max_size

    errors.add(:file, "must be less than #{max_size / 1.megabyte}MB")
  end
end
