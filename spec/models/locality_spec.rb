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

require 'rails_helper'

RSpec.describe Locality, type: :model do
  subject(:locality) { build(:locality) }

  describe 'associations' do
    it 'belongs to province' do
      expect(subject).to belong_to(:province)
    end

    it 'has many vet service areas' do
      expect(subject).to have_many(:vet_service_areas).dependent(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of indec_code' do
      expect(subject).to validate_presence_of(:indec_code)
    end

    it 'validates uniqueness of indec_code' do
      expect(subject).to validate_uniqueness_of(:indec_code).case_insensitive
    end

    it 'validates length of indec_code' do
      expect(subject).to validate_length_of(:indec_code).is_equal_to(11)
    end

    it 'validates presence of name' do
      expect(subject).to validate_presence_of(:name)
    end

    it 'defines category enum with string values' do
      expect(Locality.categories).to eq({
                                          'city' => 'Ciudad',
                                          'simple_locality' => 'Localidad simple (LS)',
                                          'compound_locality' => 'Localidad compuesta (LC)',
                                          'hamlet' => 'Paraje (P)',
                                          'other' => 'Otros'
                                        })
    end

    it 'allows valid categories' do
      expect(subject).to allow_value(:city).for(:category)
      expect(subject).to allow_value(:simple_locality).for(:category)
      expect(subject).to allow_value(:compound_locality).for(:category)
      expect(subject).to allow_value(:hamlet).for(:category)
      expect(subject).to allow_value(:other).for(:category)
    end

    it 'allows blank category' do
      expect(subject).to allow_value(nil).for(:category)
    end
  end

  describe 'scopes' do
    let(:province) { create(:province) }

    before do
      Locality.delete_all
    end

    it 'orders by name' do
      create(:locality, name: 'Zebra', province: province)
      create(:locality, name: 'Alpha', province: province)

      expect(Locality.ordered_by_name.pluck(:name)).to eq(%w[Alpha Zebra])
    end

    it 'filters by province' do
      province1 = create(:province)
      province2 = create(:province)
      locality1 = create(:locality, province: province1)
      locality2 = create(:locality, province: province2)

      expect(Locality.by_province(province1.id)).to include(locality1)
      expect(Locality.by_province(province1.id)).not_to include(locality2)
    end

    it 'filters cities' do
      city = create(:locality, :city, province: province)
      town = create(:locality, category: :simple_locality, province: province)

      expect(Locality.cities).to include(city)
      expect(Locality.cities).not_to include(town)
    end
  end

  describe '#to_s' do
    it 'returns locality and province name' do
      province = build(:province, name: 'Buenos Aires')
      locality.name = 'La Plata'
      locality.province = province

      expect(locality.to_s).to eq('La Plata, Buenos Aires')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(locality).to be_valid
    end

    it 'creates la_plata trait correctly' do
      la_plata = build(:locality, :la_plata)

      expect(la_plata.indec_code).to eq('06001010000')
      expect(la_plata.name).to eq('La Plata')
      expect(la_plata.category).to eq('city')
    end

    it 'generates unique indec_codes' do
      locality1 = create(:locality)
      locality2 = create(:locality)

      expect(locality1.indec_code).not_to eq(locality2.indec_code)
    end

    it 'creates associated province' do
      locality = create(:locality)

      expect(locality.province).to be_present
    end
  end
end
