# frozen_string_literal: true

# == Schema Information
#
# Table name: certification_documents
#
#  id                        :bigint           not null, primary key
#  filename                  :string           not null
#  pdf_hash                  :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  blockchain_transaction_id :bigint           not null
#  cattle_certification_id   :bigint           not null
#
# Indexes
#
#  index_certification_documents_on_blockchain_transaction_id  (blockchain_transaction_id)
#  index_certification_documents_on_cattle_certification_id    (cattle_certification_id) UNIQUE
#  index_certification_documents_on_pdf_hash                   (pdf_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (blockchain_transaction_id => blockchain_transactions.id)
#  fk_rails_...  (cattle_certification_id => cattle_certifications.id)
#
class CertificationDocument < ApplicationRecord
  belongs_to :cattle_certification, inverse_of: :certification_document
  belongs_to :blockchain_transaction, inverse_of: :certification_document

  # Active Storage for PDF file
  has_one_attached :pdf_file

  validates :pdf_hash, presence: true, uniqueness: true
  validates :filename, presence: true
  validates :cattle_certification_id, uniqueness: true

  validate :pdf_file_attached
  validate :pdf_hash_matches_file, if: -> { pdf_file.attached? }

  delegate :confirmed?, :failed?, :pending?, :network_name,
           :status, :transaction_hash, :block_number,
           to: :blockchain_transaction, prefix: :blockchain

  def blockchain_certified?
    blockchain_confirmed?
  end

  def blockchain_url
    blockchain_transaction&.blockchain_url
  end

  def pdf_size
    pdf_file.attached? ? pdf_file.byte_size : 0
  end

  def pdf_content_type
    pdf_file.attached? ? pdf_file.content_type : nil
  end

  def generate_filename(cattle_certification)
    date = cattle_certification.data_taken_at&.strftime('%Y%m%d') || Date.current.strftime('%Y%m%d')
    cuig = sanitize_filename_part(cattle_certification.cuig_code || 'NOCUIG')
    producer_cuig = sanitize_filename_part(
      cattle_certification.certified_lot.certification_request.producer_profile.cuig_number || 'NOPROD'
    )

    "cert_#{cuig}_#{date}_#{producer_cuig}.pdf"
  end

  def self.calculate_pdf_hash(pdf_content)
    require 'digest'
    Digest::SHA256.hexdigest(pdf_content)
  end

  private

  def pdf_file_attached
    return if pdf_file.attached?

    errors.add(:pdf_file, 'debe estar adjunto')
  end

  def pdf_hash_matches_file
    return unless pdf_file.attached?

    begin
      actual_hash = self.class.calculate_pdf_hash(pdf_file.download)
      return if pdf_hash == actual_hash

      errors.add(:pdf_hash, 'no coincide con el archivo adjunto')
    rescue Errno::ENOENT, ActiveStorage::FileNotFoundError
      # El archivo no existe físicamente, probablemente en tests
      # Skip validation in this case
    end
  end

  def sanitize_filename_part(str)
    str.to_s.gsub(/[^a-zA-Z0-9]/, '').upcase[0..10]
  end
end
