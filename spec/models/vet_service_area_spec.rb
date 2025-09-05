# frozen_string_literal: true

# == Schema Information
#
# Table name: vet_service_areas
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  locality_id    :bigint           not null
#  vet_profile_id :bigint           not null
#
# Indexes
#
#  index_vet_service_areas_on_locality_id     (locality_id)
#  index_vet_service_areas_on_vet_profile_id  (vet_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (locality_id => localities.id)
#  fk_rails_...  (vet_profile_id => vet_profiles.id)
#

require 'rails_helper'

RSpec.describe VetServiceArea, type: :model do
  subject(:vet_service_area) { build(:vet_service_area) }

  describe 'associations' do
    it 'belongs to vet profile' do
      expect(subject).to belong_to(:vet_profile)
    end

    it 'belongs to locality' do
      expect(subject).to belong_to(:locality)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of vet_profile_id scoped to locality_id' do
      create(:vet_service_area)
      expect(subject).to validate_uniqueness_of(:vet_profile_id).scoped_to(:locality_id)
    end

    it 'prevents duplicate service areas for same vet and locality' do
      vet_profile = create(:vet_profile)
      locality = create(:locality)
      create(:vet_service_area, vet_profile: vet_profile, locality: locality)

      duplicate_area = build(:vet_service_area, vet_profile: vet_profile, locality: locality)

      expect(duplicate_area).not_to be_valid
    end

    it 'allows same vet to serve multiple localities' do
      vet_profile = create(:vet_profile)
      locality1 = create(:locality)
      locality2 = create(:locality)

      create(:vet_service_area, vet_profile: vet_profile, locality: locality1)
      area2 = build(:vet_service_area, vet_profile: vet_profile, locality: locality2)

      expect(area2).to be_valid
    end

    it 'allows multiple vets to serve same locality' do
      vet1 = create(:vet_profile)
      vet2 = create(:vet_profile)
      locality = create(:locality)

      create(:vet_service_area, vet_profile: vet1, locality: locality)
      area2 = build(:vet_service_area, vet_profile: vet2, locality: locality)

      expect(area2).to be_valid
    end
  end

  describe 'scopes' do
    it 'filters by province' do
      province1 = create(:province)
      province2 = create(:province)
      locality1 = create(:locality, province: province1)
      locality2 = create(:locality, province: province2)

      area1 = create(:vet_service_area, locality: locality1)
      area2 = create(:vet_service_area, locality: locality2)

      expect(VetServiceArea.by_province(province1.id)).to include(area1)
      expect(VetServiceArea.by_province(province1.id)).not_to include(area2)
    end
  end

  describe '#province' do
    it 'returns the province of the locality' do
      province = create(:province, name: 'Test Province')
      locality = create(:locality, province: province)
      service_area = build(:vet_service_area, locality: locality)

      expect(service_area.province).to eq(province)
    end
  end

  describe '#to_s' do
    it 'returns vet email and locality' do
      user = create(:user, email: 'vet@example.com')
      vet_profile = create(:vet_profile, user: user)
      province = create(:province, name: 'Test Province 2')
      locality = create(:locality, name: 'Test City', province: province)
      service_area = build(:vet_service_area, vet_profile: vet_profile, locality: locality)

      expect(service_area.to_s).to eq('vet@example.com - Test City, Test Province 2')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(vet_service_area).to be_valid
    end

    it 'creates associated vet_profile and locality' do
      service_area = create(:vet_service_area)

      expect(service_area.vet_profile).to be_present
      expect(service_area.locality).to be_present
    end
  end
end
