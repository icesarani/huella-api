# frozen_string_literal: true

# @param vet_work_schedule [VetWorkSchedule] The work schedule instance to render
# @return [JSON] JSON representation of the vet work schedule
# @example Rendering a work schedule
#   json.partial! 'api/v1/vet_work_schedules/vet_work_schedule', vet_work_schedule: schedule
json.id vet_work_schedule.id
json.monday vet_work_schedule.monday
json.tuesday vet_work_schedule.tuesday
json.wednesday vet_work_schedule.wednesday
json.thursday vet_work_schedule.thursday
json.friday vet_work_schedule.friday
json.saturday vet_work_schedule.saturday
json.sunday vet_work_schedule.sunday
json.created_at vet_work_schedule.created_at
json.updated_at vet_work_schedule.updated_at
