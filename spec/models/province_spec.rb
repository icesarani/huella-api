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

require 'rails_helper'

RSpec.describe Province, type: :model do
  subject(:province) { build(:province) }

  describe 'associations' do
    it 'has many localities' do
      expect(subject).to have_many(:localities).dependent(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      expect(subject).to validate_presence_of(:name)
    end

    it 'allows any indec_code value' do
      expect(subject).to allow_value('01').for(:indec_code)
      expect(subject).to allow_value('123').for(:indec_code)
      expect(subject).to allow_value('AB').for(:indec_code)
      expect(subject).to allow_value(nil).for(:indec_code)
    end

    it 'allows any iso_code value' do
      expect(subject).to allow_value('AR-A').for(:iso_code)
      expect(subject).to allow_value('AR-1').for(:iso_code)
      expect(subject).to allow_value('XX-A').for(:iso_code)
      expect(subject).to allow_value('ARA').for(:iso_code)
      expect(subject).to allow_value(nil).for(:iso_code)
      expect(subject).to allow_value('').for(:iso_code)
    end
  end

  describe 'scopes' do
    it 'orders by name' do
      create(:province, name: 'Zebra')
      create(:province, name: 'Alpha')

      expect(Province.ordered_by_name.pluck(:name).first).to eq('Alpha')
    end
  end

  describe '#to_s' do
    it 'returns the province name' do
      province.name = 'Buenos Aires'

      expect(province.to_s).to eq('Buenos Aires')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(province).to be_valid
    end

    it 'creates buenos_aires trait correctly' do
      ba_province = build(:province, :buenos_aires)

      expect(ba_province.indec_code).to eq('06')
      expect(ba_province.name).to eq('Buenos Aires')
      expect(ba_province.iso_code).to eq('AR-B')
    end

    it 'generates unique indec_codes' do
      province1 = create(:province)
      province2 = create(:province)

      expect(province1.indec_code).not_to eq(province2.indec_code)
    end
  end
end
