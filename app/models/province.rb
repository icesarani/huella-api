# frozen_string_literal: true

# == Schema Information
#
# Table name: provinces
#
#  id         :bigint           not null, primary key
#  indec_code :string
#  iso_code   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_provinces_on_indec_code  (indec_code) UNIQUE
#

class Province < ApplicationRecord
  has_many :localities, dependent: :destroy

  validates :indec_code, presence: true, uniqueness: true, length: { is: 2 }
  validates :name, presence: true, uniqueness: true
  validates :iso_code, length: { is: 4 }, format: { with: /\AAR-[A-Z]\z/ }, allow_blank: true

  scope :ordered_by_name, -> { order(:name) }

  def to_s
    name
  end
end
