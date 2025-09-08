# frozen_string_literal: true

json.certification_request do # rubocop:disable Metrics/BlockLength
  # Basic certification request attributes
  json.id certification_request.id
  json.address certification_request.address
  json.intended_animal_group certification_request.intended_animal_group
  json.declared_lot_weight certification_request.declared_lot_weight
  json.declared_lot_age certification_request.declared_lot_age
  json.cattle_breed certification_request.cattle_breed
  json.preferred_time_range certification_request.preferred_time_range
  json.scheduled_date certification_request.scheduled_date
  json.scheduled_time certification_request.scheduled_time
  json.status certification_request.status
  json.created_at certification_request.created_at
  json.updated_at certification_request.updated_at

  # Locality information
  if certification_request.locality.present?
    json.locality do
      json.partial! 'api/v1/localities/locality', locality: certification_request.locality
    end
  else
    json.locality nil
  end

  # Producer profile information
  if certification_request.producer_profile.present?
    json.producer_profile do
      json.id certification_request.producer_profile.id
      json.name certification_request.producer_profile.name
      json.cuig_number certification_request.producer_profile.cuig_number
    end
  else
    json.producer_profile nil
  end

  # Veterinarian profile information (if assigned)
  if certification_request.vet_profile.present?
    json.vet_profile do
      json.id certification_request.vet_profile.id
      json.first_name certification_request.vet_profile.first_name
      json.last_name certification_request.vet_profile.last_name
      json.license_number certification_request.vet_profile.license_number
    end
  else
    json.vet_profile nil
  end

  # File upload information (if present)
  if certification_request.file_upload.present?
    json.file_upload do
      json.partial! 'api/v1/file_uploads/file_upload', file_upload: certification_request.file_upload
    end
  else
    json.file_upload nil
  end

  # Certified lot information (if present)
  if certification_request.certified_lot.present?
    json.certified_lot do
      json.partial! 'api/v1/certified_lots/certified_lot', certified_lot: certification_request.certified_lot
    end
  else
    json.certified_lot nil
  end
end
