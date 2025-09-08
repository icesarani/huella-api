# frozen_string_literal: true

# Basic certified lot attributes
json.id certified_lot.id
json.created_at certified_lot.created_at
json.updated_at certified_lot.updated_at

# Certification request information
if certified_lot.certification_request.present?
  json.certification_request do
    json.id certified_lot.certification_request.id
    json.address certified_lot.certification_request.address
    json.intended_animal_group certified_lot.certification_request.intended_animal_group
    json.declared_lot_weight certified_lot.certification_request.declared_lot_weight
    json.declared_lot_age certified_lot.certification_request.declared_lot_age
    json.cattle_breed certified_lot.certification_request.cattle_breed
    json.status certified_lot.certification_request.status
  end
else
  json.certification_request nil
end

# Cattle certifications
json.cattle_certifications certified_lot.cattle_certifications do |cattle_cert|
  json.partial! 'api/v1/cattle_certifications/cattle_certification', cattle_certification: cattle_cert
end
