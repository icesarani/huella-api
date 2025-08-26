# frozen_string_literal: true

# == Schema Information
#
# Table name: localities
#
#  id          :integer          not null, primary key
#  indec_code  :string
#  name        :string
#  category    :string
#  province_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_localities_on_indec_code   (indec_code) UNIQUE
#  index_localities_on_province_id  (province_id)
#

class Locality < ApplicationRecord
  belongs_to :province
  has_many :vet_service_areas, dependent: :destroy

  validates :indec_code, presence: true, uniqueness: true, length: { is: 11 }
  validates :name, presence: true

  enum :category, {
    city: 'Ciudad',
    simple_locality: 'Localidad simple (LS)',
    compound_locality: 'Localidad compuesta (LC)',
    hamlet: 'Paraje (P)',
    other: 'Otros'
  }, default: nil

  scope :ordered_by_name, -> { order(:name) }
  scope :by_province, ->(province_id) { where(province: province_id) }
  scope :cities, -> { city }

  def to_s
    "#{name}, #{province.name}"
  end
end
