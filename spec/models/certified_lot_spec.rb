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
require 'rails_helper'

RSpec.describe CertifiedLot, type: :model do
  subject(:certified_lot) { build(:certified_lot) }

  describe 'associations' do
    it { is_expected.to belong_to(:certification_request) }
    it { is_expected.to have_many(:cattle_certifications).inverse_of(:certified_lot).dependent(:destroy) }
  end

  describe 'factory' do
    it 'creates valid certified_lot' do
      expect(certified_lot).to be_valid
    end

    it 'creates certified_lot with certification_request association' do
      certified_lot.save!
      expect(certified_lot.certification_request).to be_present
      expect(certified_lot.certification_request).to be_a(CertificationRequest)
    end

    describe ':with_cattle_certifications trait' do
      subject(:lot_with_cattle) { create(:certified_lot, :with_cattle_certifications) }

      it 'creates 3 cattle_certifications' do
        expect(lot_with_cattle.cattle_certifications.count).to eq(3)
      end

      it 'creates valid cattle_certifications' do
        expect(lot_with_cattle.cattle_certifications).to all(be_a(CattleCertification))
      end

      it 'all cattle_certifications are valid' do
        expect(lot_with_cattle.cattle_certifications).to all(be_valid)
      end

      it 'destroys cattle_certifications when certified_lot is destroyed' do
        cattle_ids = lot_with_cattle.cattle_certifications.pluck(:id)
        lot_with_cattle.destroy!
        cattle_ids.each do |id|
          expect(CattleCertification.exists?(id)).to be false
        end
      end
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(certified_lot).to be_valid
    end

    it 'requires certification_request' do
      certified_lot.certification_request = nil
      expect(certified_lot).not_to be_valid
      expect(certified_lot.errors[:certification_request]).to be_present
    end
  end
end
