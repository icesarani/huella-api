# frozen_string_literal: true

json.id user.id
json.email user.email

if user.producer_profile
  json.producer_profile do
    json.id user.producer_profile.id
    json.name user.producer_profile.name
    json.identity_card user.producer_profile.identity_card
    json.cuig_number user.producer_profile.cuig_number
    json.renspa_number user.producer_profile.renspa_number
  end
elsif user.vet_profile
  json.vet_profile do
    json.id user.vet_profile.id
    json.first_name user.vet_profile.first_name
    json.last_name user.vet_profile.last_name
    json.full_name user.vet_profile.full_name
    json.identity_card user.vet_profile.identity_card
    json.license_number user.vet_profile.license_number
    json.localities user.vet_profile.localities do |locality|
      json.id locality.id
      json.name locality.name
      json.province_id locality.province_id
    end
  end
end
