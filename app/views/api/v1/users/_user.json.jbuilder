# frozen_string_literal: true

json.id user.id
json.email user.email

if user.producer_profile
  json.producer_profile do
    json.partial! 'api/v1/producer_profiles/producer_profile', producer_profile: user.producer_profile
  end
elsif user.vet_profile
  json.vet_profile do
    json.partial! 'api/v1/vet_profiles/vet_profile', vet_profile: user.vet_profile
  end
end
