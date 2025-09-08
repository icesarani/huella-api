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

  validates :name, presence: true

  scope :ordered_by_name, -> { order(:name) }

  def to_s
    name
  end
end
