# frozen_string_literal: true

require 'prawn'
require 'prawn/table'

# Hide internationalization warning for Prawn fonts
Prawn::Fonts::AFM.hide_m17n_warning = true

module Utils
  class CattleCertificationPdfGenerator < ApplicationService # rubocop:disable Metrics/ClassLength
    def initialize(cattle_certification:)
      @cattle_certification = cattle_certification
      @certification_request = cattle_certification.certified_lot.certification_request
      @producer_profile = @certification_request.producer_profile
      @vet_profile = @certification_request.vet_profile
      super
    end

    def call
      generate_pdf
    end

    private

    attr_reader :cattle_certification, :certification_request, :producer_profile, :vet_profile

    def generate_pdf
      Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
        # Header
        add_header(pdf)

        # Producer information
        add_producer_section(pdf)

        # Veterinarian information
        add_veterinarian_section(pdf)

        # Animal information
        add_animal_section(pdf)

        # Footer
        add_footer(pdf)
      end.render
    end

    def add_header(pdf)
      pdf.font_size 24
      pdf.text I18n.t('pdf.cattle_certification.title'), align: :center, style: :bold

      pdf.move_down 10
      pdf.font_size 12
      pdf.text I18n.t('pdf.cattle_certification.subtitle'), align: :center

      pdf.move_down 5
      pdf.text I18n.t('pdf.cattle_certification.generated_at', date: I18n.l(Time.current, format: :long)),
               align: :center

      pdf.move_down 20
      pdf.stroke_horizontal_rule
      pdf.move_down 20
    end

    def add_producer_section(pdf) # rubocop:disable Metrics/AbcSize
      pdf.font_size 16
      pdf.text I18n.t('pdf.cattle_certification.producer_info'), style: :bold
      pdf.move_down 10

      producer_data = [
        [I18n.t('pdf.cattle_certification.producer_name'), producer_profile.name],
        [I18n.t('pdf.cattle_certification.cuig_number'), producer_profile.cuig_number],
        [I18n.t('pdf.cattle_certification.renspa_number'),
         producer_profile.renspa_number || I18n.t('pdf.common.not_available')],
        [I18n.t('pdf.cattle_certification.farm_address'), certification_request.address],
        [I18n.t('pdf.cattle_certification.locality'), certification_request.locality.name]
      ]

      pdf.table(producer_data, cell_style: { borders: [:bottom], border_width: 0.5, padding: [5, 0] }) do
        column(0).font_style = :bold
        column(0).width = 150
      end

      pdf.move_down 20
    end

    def add_veterinarian_section(pdf) # rubocop:disable Metrics/AbcSize
      pdf.font_size 16
      pdf.text I18n.t('pdf.cattle_certification.veterinarian_info'), style: :bold
      pdf.move_down 10

      vet_data = [
        [I18n.t('pdf.cattle_certification.vet_name'), "#{vet_profile.first_name} #{vet_profile.last_name}"],
        [I18n.t('pdf.cattle_certification.license_number'), vet_profile.license_number],
        [I18n.t('pdf.cattle_certification.certification_date'),
         I18n.l(cattle_certification.data_taken_at || cattle_certification.created_at, format: :long)]
      ]

      pdf.table(vet_data, cell_style: { borders: [:bottom], border_width: 0.5, padding: [5, 0] }) do
        column(0).font_style = :bold
        column(0).width = 150
      end

      pdf.move_down 20
    end

    def add_animal_section(pdf) # rubocop:disable Metrics/MethodLength
      pdf.font_size 16
      pdf.text I18n.t('pdf.cattle_certification.animal_info'), style: :bold
      pdf.move_down 10

      # Add animal photo if available
      if cattle_certification.photo.attached?
        add_animal_photo(pdf)
        pdf.move_down 10
      end

      animal_data = build_animal_data

      pdf.table(animal_data, cell_style: { borders: [:bottom], border_width: 0.5, padding: [5, 0] }) do
        column(0).font_style = :bold
        column(0).width = 180
      end

      pdf.move_down 20
    end

    def add_animal_photo(pdf)
      # Download photo to temporary file
      photo_tempfile = Tempfile.new(['cattle_photo', '.jpg'])
      photo_tempfile.binmode
      photo_tempfile.write(cattle_certification.photo.download)
      photo_tempfile.rewind

      # Add image to PDF
      pdf.image photo_tempfile.path, width: 200, height: 150, position: :center

      photo_tempfile.close
      photo_tempfile.unlink
    rescue StandardError => e
      Rails.logger.warn "Failed to add photo to PDF: #{e.message}"
      pdf.text I18n.t('pdf.cattle_certification.photo_unavailable'), align: :center, style: :italic
    end

    def build_animal_data # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      data = [
        [I18n.t('pdf.cattle_certification.cuig_code'),
         cattle_certification.cuig_code || I18n.t('pdf.common.not_available')],
        [I18n.t('pdf.cattle_certification.alternative_code'),
         cattle_certification.alternative_code || I18n.t('pdf.common.not_available')],
        [I18n.t('pdf.cattle_certification.gender'), translate_enum('gender', cattle_certification.gender)],
        [I18n.t('pdf.cattle_certification.category'), translate_enum('category', cattle_certification.category)],
        [I18n.t('pdf.cattle_certification.estimated_weight'), format_weight(cattle_certification.estimated_weight)]
      ]

      # Add optional fields
      if cattle_certification.dental_chronology.present?
        data << [I18n.t('pdf.cattle_certification.dental_chronology'),
                 translate_enum('dental_chronology',
                                cattle_certification.dental_chronology)]
      end
      if cattle_certification.pregnant.present?
        data << [I18n.t('pdf.cattle_certification.pregnant'),
                 format_boolean(cattle_certification.pregnant)]
      end
      if cattle_certification.pregnancy_diagnosis_method.present?
        data << [I18n.t('pdf.cattle_certification.pregnancy_method'),
                 translate_enum('pregnancy_diagnosis_method',
                                cattle_certification.pregnancy_diagnosis_method)]
      end
      if cattle_certification.corporal_condition.present?
        data << [I18n.t('pdf.cattle_certification.corporal_condition'),
                 cattle_certification.corporal_condition]
      end
      if cattle_certification.brucellosis_diagnosis.present?
        data << [I18n.t('pdf.cattle_certification.brucellosis_diagnosis'),
                 cattle_certification.brucellosis_diagnosis]
      end
      if cattle_certification.geolocation_points.present?
        data << [I18n.t('pdf.cattle_certification.geolocation'),
                 format_coordinates(cattle_certification.geolocation_points)]
      end
      if cattle_certification.comments.present?
        data << [I18n.t('pdf.cattle_certification.comments'),
                 cattle_certification.comments]
      end

      data
    end

    def add_footer(pdf) # rubocop:disable Metrics/MethodLength
      pdf.move_down 30
      pdf.stroke_horizontal_rule
      pdf.move_down 15

      pdf.font_size 18
      pdf.text I18n.t('pdf.cattle_certification.signature'), align: :center, style: :bold

      pdf.move_down 10
      pdf.font_size 12
      pdf.text I18n.t('pdf.cattle_certification.signature_subtitle'), align: :center

      pdf.move_down 20
      pdf.font_size 8
      pdf.text I18n.t('pdf.cattle_certification.disclaimer'), align: :center, style: :italic
    end

    # Helper methods for formatting

    def translate_enum(field, value)
      return I18n.t('pdf.common.not_available') unless value.present?

      I18n.t("enums.cattle_certification.#{field}.#{value}", default: value.humanize)
    end

    def format_weight(weight)
      return I18n.t('pdf.common.not_available') unless weight.present?

      I18n.t('pdf.cattle_certification.weight_format', weight: weight)
    end

    def format_boolean(value)
      return I18n.t('pdf.common.not_available') if value.nil?

      value ? I18n.t('pdf.common.yes') : I18n.t('pdf.common.no')
    end

    def format_coordinates(coordinates)
      return I18n.t('pdf.common.not_available') unless coordinates.present? && coordinates['lat'] && coordinates['lng']

      I18n.t('pdf.cattle_certification.coordinates_format',
             lat: coordinates['lat'],
             lng: coordinates['lng'])
    end
  end
end
