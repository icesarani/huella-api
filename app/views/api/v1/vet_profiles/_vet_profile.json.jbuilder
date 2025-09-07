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
if vet_profile.vet_work_schedule.present?
  json.work_schedule do
    json.partial! 'api/v1/vet_work_schedules/vet_work_schedule', vet_work_schedule: vet_profile.vet_work_schedule
  end
else
  json.work_schedule nil
end
