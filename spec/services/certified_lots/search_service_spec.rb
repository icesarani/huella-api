# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertifiedLots::SearchService, type: :service do
  subject(:service) { described_class.new }

  describe '#call' do
    before do
      # Clean up any existing data to avoid conflicts with seeds
      CertifiedLot.destroy_all
      CertificationRequest.destroy_all
    end

    let!(:locality) { create(:locality) }
    let(:producer_profile) { create(:producer_profile) }
    let(:vet_profile) { create(:vet_profile) }

    context 'when there are no certified lots' do
      it 'returns an empty relation' do
        result = service.call
        expect(result).to be_empty
        expect(result).to be_a(ActiveRecord::Relation)
      end
    end

    context 'when there are certified lots' do
      let!(:first_certification_request) do
        create(:certification_request, :executed,
               producer_profile: producer_profile,
               locality: locality,
               vet_profile: vet_profile)
      end

      let!(:second_certification_request) do
        create(:certification_request, :executed,
               producer_profile: create(:producer_profile),
               locality: locality,
               vet_profile: vet_profile)
      end

      let!(:first_certified_lot) do
        create(:certified_lot, certification_request: first_certification_request)
      end

      let!(:second_certified_lot) do
        create(:certified_lot, certification_request: second_certification_request)
      end

      it 'returns all certified lots' do
        result = service.call
        expect(result.count).to eq(2)
        expect(result).to include(first_certified_lot, second_certified_lot)
      end

      it 'returns an ActiveRecord::Relation' do
        result = service.call
        expect(result).to be_a(ActiveRecord::Relation)
      end

      it 'allows further chaining of queries' do
        result = service.call.where(certification_request: first_certification_request)
        expect(result.count).to eq(1)
        expect(result.first).to eq(first_certified_lot)
      end

      context 'with cattle certifications' do
        let!(:first_cattle_certifications_lot) do
          create_list(:cattle_certification, 2, certified_lot: first_certified_lot)
        end

        let!(:second_cattle_certifications_lot) do
          create_list(:cattle_certification, 3, certified_lot: second_certified_lot)
        end

        it 'returns certified lots with their cattle certifications' do
          result = service.call.includes(:cattle_certifications)

          first_lot = result.find { |lot| lot.id == first_certified_lot.id }
          second_lot = result.find { |lot| lot.id == second_certified_lot.id }

          expect(first_lot.cattle_certifications.count).to eq(2)
          expect(second_lot.cattle_certifications.count).to eq(3)
        end
      end

      context 'with different certification request statuses' do
        let!(:certification_request_created) do
          create(:certification_request, :created,
                 producer_profile: create(:producer_profile),
                 locality: locality)
        end

        let!(:certification_request_assigned) do
          create(:certification_request, :assigned,
                 producer_profile: create(:producer_profile),
                 locality: locality,
                 vet_profile: vet_profile)
        end

        let!(:certified_lot_with_created_request) do
          create(:certified_lot, certification_request: certification_request_created)
        end

        let!(:certified_lot_with_assigned_request) do
          create(:certified_lot, certification_request: certification_request_assigned)
        end

        it 'returns certified lots regardless of certification request status' do
          result = service.call
          expect(result).to include(
            first_certified_lot,
            second_certified_lot,
            certified_lot_with_created_request,
            certified_lot_with_assigned_request
          )
          expect(result.count).to eq(4)
        end
      end
    end

    context 'performance considerations' do
      before do
        # Create multiple certified lots with associations
        5.times do
          request = create(:certification_request, :executed,
                           producer_profile: create(:producer_profile),
                           locality: locality,
                           vet_profile: vet_profile)
          lot = create(:certified_lot, certification_request: request)
          create_list(:cattle_certification, 10, certified_lot: lot)
        end
      end

      it 'returns a relation that can be optimized with includes' do
        # This test verifies that the service returns a relation
        # that can be optimized by the controller
        result = service.call

        # The controller can then add includes to avoid N+1 queries
        optimized_result = result.includes(
          :cattle_certifications,
          certification_request: %i[producer_profile vet_profile locality]
        )

        expect(optimized_result.count).to eq(5)

        # Verify that associations can be accessed without errors
        optimized_result.each do |lot|
          expect { lot.cattle_certifications.to_a }.not_to raise_error
          expect { lot.certification_request&.producer_profile }.not_to raise_error
          expect { lot.certification_request&.vet_profile }.not_to raise_error
          expect { lot.certification_request&.locality }.not_to raise_error
        end
      end
    end
  end
end
