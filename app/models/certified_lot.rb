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
class CertifiedLot < ApplicationRecord
  belongs_to :certification_request
  has_many :cattle_certifications, inverse_of: :certified_lot, dependent: :destroy
end
