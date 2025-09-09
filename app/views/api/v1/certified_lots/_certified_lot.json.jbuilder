# frozen_string_literal: true

# Basic certified lot attributes
json.id certified_lot.id
json.created_at certified_lot.created_at
json.updated_at certified_lot.updated_at

# Certification request information
if certified_lot.certification_request.present?
  json.certification_request do # rubocop:disable Metrics/BlockLength
    json.id certified_lot.certification_request.id
    json.address certified_lot.certification_request.address
    json.intended_animal_group certified_lot.certification_request.intended_animal_group
    json.declared_lot_weight certified_lot.certification_request.declared_lot_weight
    json.declared_lot_age certified_lot.certification_request.declared_lot_age
    json.cattle_breed certified_lot.certification_request.cattle_breed
    json.preferred_time_range certified_lot.certification_request.preferred_time_range
    json.scheduled_date certified_lot.certification_request.scheduled_date
    json.scheduled_time certified_lot.certification_request.scheduled_time
    json.status certified_lot.certification_request.status
    json.created_at certified_lot.certification_request.created_at
    json.updated_at certified_lot.certification_request.updated_at

    # Locality information
    if certified_lot.certification_request.locality.present?
      json.locality do
        json.partial! 'api/v1/localities/locality', locality: certified_lot.certification_request.locality
      end
    else
      json.locality nil
    end

    # Producer profile information (using partial)
    if certified_lot.certification_request.producer_profile.present?
      json.producer_profile do
        json.partial! 'api/v1/producer_profiles/producer_profile',
                      producer_profile: certified_lot.certification_request.producer_profile
      end
    else
      json.producer_profile nil
    end

    # Veterinarian profile information (using partial - if assigned)
    if certified_lot.certification_request.vet_profile.present?
      json.vet_profile do
        json.partial! 'api/v1/vet_profiles/vet_profile', vet_profile: certified_lot.certification_request.vet_profile
      end
    else
      json.vet_profile nil
    end

    # File upload information (if present)
    if certified_lot.certification_request.file_upload.present?
      json.file_upload do
        json.partial! 'api/v1/file_uploads/file_upload', file_upload: certified_lot.certification_request.file_upload
      end
    else
      json.file_upload nil
    end
  end
else
  json.certification_request nil
end

# Cattle certifications
json.cattle_certifications certified_lot.cattle_certifications do |cattle_cert|
  json.partial! 'api/v1/cattle_certifications/cattle_certification', cattle_certification: cattle_cert
end
