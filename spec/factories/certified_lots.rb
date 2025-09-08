# frozen_string_literal: true

# == Schema Information
#
# Table name: certified_lots
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  certification_request_id :bigint           not null
#
# Indexes
#
#  index_certified_lots_on_certification_request_id  (certification_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (certification_request_id => certification_requests.id)
#
FactoryBot.define do
  factory :certified_lot do
    certification_request

    trait :with_cattle_certifications do
      after(:create) do |certified_lot|
        create_list(:cattle_certification, 3, certified_lot: certified_lot)
      end
    end
  end
end
