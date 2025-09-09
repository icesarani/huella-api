# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :certification_document do
    cattle_certification
    blockchain_transaction
    filename { "cert_#{SecureRandom.hex(4)}_#{Date.current.strftime('%Y%m%d')}_#{SecureRandom.hex(4)}.pdf" }
    pdf_hash { "0x#{SecureRandom.hex(32)}" }

    # Skip validation during factory creation
    to_create do |instance|
      instance.save!(validate: false)
    end

    trait :blockchain_confirmed do
      association :blockchain_transaction, :confirmed
    end

    trait :blockchain_failed do
      association :blockchain_transaction, :failed
    end
  end

  # Factory specifically for tests that need PDF files attached
  factory :certification_document_with_pdf, parent: :certification_document do
    transient do
      pdf_content { "fake PDF content for testing #{SecureRandom.hex(8)}" }
      skip_hash_validation { true }
    end

    pdf_hash { CertificationDocument.calculate_pdf_hash(pdf_content) }

    after(:create) do |cert_doc, evaluator|
      # Create a temporary file instead of using StringIO
      temp_file = Tempfile.new(['test_pdf', '.pdf'])
      temp_file.write(evaluator.pdf_content)
      temp_file.rewind

      # Conditionally override the validation method to avoid file download errors
      cert_doc.define_singleton_method(:pdf_hash_matches_file) { true } if evaluator.skip_hash_validation

      # Attach PDF after creation, bypassing validations
      cert_doc.pdf_file.attach(
        io: temp_file,
        filename: cert_doc.filename,
        content_type: 'application/pdf'
      )

      temp_file.close!
    end

    # Trait for tests that want to test hash validation
    trait :with_hash_validation do
      transient do
        skip_hash_validation { false }
      end
    end
  end
end
