# frozen_string_literal: true

# == Schema Information
#
# Table name: localities
#
#  id          :bigint           not null, primary key
#  category    :string
#  indec_code  :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  province_id :bigint           not null
#
# Indexes
#
#  index_localities_on_indec_code   (indec_code) UNIQUE
#  index_localities_on_province_id  (province_id)
#
# Foreign Keys
#
#  fk_rails_...  (province_id => provinces.id)
#

class Locality < ApplicationRecord
  belongs_to :province
  has_many :vet_service_areas, dependent: :destroy

  validates :name, presence: true

  scope :ordered_by_name, -> { order(:name) }
  scope :by_province, ->(province_id) { where(province: province_id) }

  def to_s
    "#{name}, #{province.name}"
  end
end
