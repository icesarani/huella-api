# frozen_string_literal: true

json.id vet_profile.id
json.first_name vet_profile.first_name
json.last_name vet_profile.last_name
json.full_name vet_profile.full_name
json.identity_card vet_profile.identity_card
json.license_number vet_profile.license_number
json.created_at vet_profile.created_at
json.updated_at vet_profile.updated_at
json.localities vet_profile.localities do |locality|
  json.id locality.id
  json.name locality.name
  json.province_id locality.province_id
end
