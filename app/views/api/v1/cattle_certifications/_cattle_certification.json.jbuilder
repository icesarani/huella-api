# frozen_string_literal: true

# Basic cattle certification attributes
json.id cattle_certification.id
json.cuig_code cattle_certification.cuig_code
json.alternative_code cattle_certification.alternative_code
json.gender cattle_certification.gender
json.category cattle_certification.category
json.dental_chronology cattle_certification.dental_chronology
json.estimated_weight cattle_certification.estimated_weight
json.pregnant cattle_certification.pregnant
json.pregnancy_diagnosis_method cattle_certification.pregnancy_diagnosis_method
json.pregnancy_service_range cattle_certification.pregnancy_service_range
json.corporal_condition cattle_certification.corporal_condition
json.brucellosis_diagnosis cattle_certification.brucellosis_diagnosis
json.comments cattle_certification.comments
json.geolocation_points cattle_certification.geolocation_points
json.data_taken_at cattle_certification.data_taken_at
json.created_at cattle_certification.created_at
json.updated_at cattle_certification.updated_at

# Photo attachment URL
if cattle_certification.photo.attached?
  json.photo_url rails_blob_url(cattle_certification.photo)
else
  json.photo_url nil
end

# Blockchain certification information
if cattle_certification.certification_document.present?
  json.blockchain_certification do
    json.pdf_hash cattle_certification.pdf_hash
    json.transaction_hash cattle_certification.blockchain_transaction_hash
    json.blockchain_status cattle_certification.blockchain_status
    json.blockchain_url cattle_certification.blockchain_url
    json.pdf_filename cattle_certification.certification_filename
    json.pdf_available cattle_certification.pdf_available?
    json.blockchain_certified cattle_certification.blockchain_certified?
    json.certified_at cattle_certification.certification_document.created_at
    json.network_name cattle_certification.certification_document.blockchain_transaction.network_name
  end
else
  json.blockchain_certification nil
end
