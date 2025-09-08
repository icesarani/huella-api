# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Utils::CattleCertificationPdfGenerator, type: :service do
  let(:vet_profile) { create(:vet_profile) }
  let(:producer_profile) { create(:producer_profile) }
  let(:locality) { create(:locality) }
  let(:certification_request) do
    create(:certification_request,
           producer_profile: producer_profile,
           vet_profile: vet_profile,
           locality: locality)
  end
  let(:certified_lot) { create(:certified_lot, certification_request: certification_request) }
  let(:cattle_certification) { create(:cattle_certification, certified_lot: certified_lot) }
  let(:service) { described_class.new(cattle_certification: cattle_certification) }

  around do |example|
    I18n.with_locale(:es) do
      example.run
    end
  end

  describe '#call' do
    context 'with complete cattle certification data' do
      let(:cattle_certification) do
        create(:cattle_certification, :with_photo, :complete_data, certified_lot: certified_lot)
      end

      it 'generates a PDF successfully' do
        result = service.call

        expect(result).to be_present
        expect(result).to be_a(String)
        expect(result.size).to be > 0
      end

      it 'includes all required sections' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        # Header
        expect(text_content).to include('Certificado de Ganado')
        expect(text_content).to include('Huella Rural')

        # Producer info
        expect(text_content).to include('Información del Productor')
        expect(text_content).to include(producer_profile.name)
        expect(text_content).to include(producer_profile.cuig_number)

        # Veterinarian info
        expect(text_content).to include('Información del Veterinario')
        expect(text_content).to include(vet_profile.first_name)
        expect(text_content).to include(vet_profile.last_name)
        expect(text_content).to include(vet_profile.license_number)

        # Animal info
        expect(text_content).to include('Información del Animal')
        expect(text_content).to include(cattle_certification.cuig_code) if cattle_certification.cuig_code
      end
    end

    context 'with minimal cattle certification data' do
      let(:cattle_certification) do
        create(:cattle_certification, :minimal_data, certified_lot: certified_lot)
      end

      it 'generates a PDF with minimal data' do
        result = service.call

        expect(result).to be_present
        expect(result).to be_a(String)
      end

      it 'shows "No disponible" for missing optional fields' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        expect(text_content).to include('No disponible')
      end
    end

    context 'with cattle photo attached' do
      let(:cattle_certification) do
        create(:cattle_certification, :with_photo, certified_lot: certified_lot)
      end

      it 'includes the photo in the PDF' do
        result = service.call
        expect(result).to be_present

        # Verify PDF is larger when photo is included (approximate check)
        expect(result.size).to be > 10_000
      end
    end

    context 'without cattle photo' do
      it 'generates PDF without photo section' do
        result = service.call
        expect(result).to be_present
      end
    end

    context 'with invalid photo attachment' do
      let(:cattle_certification) do
        create(:cattle_certification, certified_lot: certified_lot).tap do |cert|
          # Mock a photo attachment that will fail
          allow(cert).to receive(:photo).and_return(double(attached?: true, download: lambda {
            raise StandardError, 'Download failed'
          }))
        end
      end

      it 'handles photo errors gracefully' do
        expect(Rails.logger).to receive(:warn).with(/Failed to add photo to PDF/)

        result = service.call
        expect(result).to be_present

        pdf_reader = PDF::Reader.new(StringIO.new(result))
        text_content = pdf_reader.pages.map(&:text).join(' ')
        expect(text_content).to include('Foto no disponible')
      end
    end

    context 'with geolocation data' do
      let(:cattle_certification) do
        create(:cattle_certification,
               certified_lot: certified_lot,
               geolocation_points: { 'lat' => -34.6037, 'lng' => -58.3816 })
      end

      it 'formats coordinates correctly' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        expect(text_content).to include('Lat: -34.6037, Lng: -58.3816')
      end
    end

    context 'with pregnancy information' do
      let(:cattle_certification) do
        create(:cattle_certification,
               certified_lot: certified_lot,
               pregnant: true,
               pregnancy_diagnosis_method: 'ultrasound')
      end

      it 'includes pregnancy information' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        expect(text_content).to include('Si') # For pregnant: true
        expect(text_content).to include('Ultrasonido') # Translated pregnancy method
      end
    end

    context 'with all optional enum fields' do
      let(:cattle_certification) do
        create(:cattle_certification,
               certified_lot: certified_lot,
               dental_chronology: 'permanent_incisors',
               pregnancy_diagnosis_method: 'palpation')
      end

      it 'translates enum values correctly' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        expect(text_content).to include('Incisivos permanentes')
        expect(text_content).to include('Palpación')
      end
    end

    context 'error handling' do
      it 'raises error when cattle_certification is nil' do
        expect { described_class.new(cattle_certification: nil).call }.to raise_error(NoMethodError)
      end

      it 'handles missing associations gracefully' do
        # Create a certification with minimal associations
        minimal_certification = build(:cattle_certification, certified_lot: nil)

        expect { described_class.new(cattle_certification: minimal_certification).call }.to raise_error
      end
    end

    context 'with comments' do
      let(:cattle_certification) do
        create(:cattle_certification,
               certified_lot: certified_lot,
               comments: 'Animal en excelente estado de salud')
      end

      it 'includes comments in the PDF' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        expect(text_content).to include('Animal en excelente estado de salud')
      end
    end

    context 'date formatting' do
      let(:specific_date) { Time.zone.parse('2024-12-15 14:30:00') }
      let(:cattle_certification) do
        create(:cattle_certification,
               certified_lot: certified_lot,
               data_taken_at: specific_date)
      end

      it 'formats dates in Spanish locale' do
        pdf_content = service.call
        pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))
        text_content = pdf_reader.pages.map(&:text).join(' ')

        # Check that the date appears in the PDF (exact format depends on I18n configuration)
        expect(text_content).to include('2024')
        expect(text_content).to include('15')
      end
    end
  end

  describe 'PDF structure validation' do
    it 'creates a valid PDF document' do
      pdf_content = service.call

      # Basic PDF validation
      expect(pdf_content).to start_with('%PDF')

      # Should be readable by PDF::Reader
      expect { PDF::Reader.new(StringIO.new(pdf_content)) }.not_to raise_error
    end

    it 'contains expected number of pages' do
      pdf_content = service.call
      pdf_reader = PDF::Reader.new(StringIO.new(pdf_content))

      expect(pdf_reader.page_count).to be >= 1
      expect(pdf_reader.page_count).to be <= 2
    end
  end
end
