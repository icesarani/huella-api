# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificationRequests::VeterinarianAssignmentService, type: :service do
  describe '#call!' do
    context 'when available veterinarian exists' do
      let!(:locality) { create(:locality) }
      let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
      let!(:certification_request) do
        create(:certification_request,
               locality: locality,
               preferred_time_range: (Time.parse('2024-12-02 09:00:00 UTC')..Time.parse('2024-12-02 11:00:00 UTC')))
      end

      before do
        # Setup vet to serve the same locality
        vet_profile.vet_service_areas.first.update!(locality: locality)
        # Setup vet to work on Monday mornings
        vet_profile.vet_work_schedule.update!(monday: 'morning')
      end
      it 'assigns a veterinarian to the certification request' do
        service = described_class.new(certification_request: certification_request)

        result = service.call!

        expect(result.vet_profile).to be_present
      end

      it 'sets scheduled date and time' do
        service = described_class.new(certification_request: certification_request)

        result = service.call!

        expect(result.scheduled_date).to be_present
      end

      it 'updates status to assigned' do
        service = described_class.new(certification_request: certification_request)

        result = service.call!

        expect(result.status).to eq('assigned')
      end

      it 'assigns the veterinarian serving the locality' do
        service = described_class.new(certification_request: certification_request)

        result = service.call!

        expect(result.vet_profile).to eq(vet_profile)
      end
    end

    context 'when no veterinarian serves the locality' do
      let!(:locality) { create(:locality) }
      let!(:other_locality) { create(:locality) }
      let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
      let!(:certification_request) do
        create(:certification_request, locality: other_locality)
      end

      before do
        # Setup vet to serve different locality
        vet_profile.vet_service_areas.first.update!(locality: locality)
        vet_profile.vet_work_schedule.update!(monday: 'morning')
      end

      it 'the certification requests do not add any vet_profile' do
        certification_request_handled = described_class.new(certification_request:).call!

        expect(certification_request_handled.vet_profile).to be_nil
      end
    end

    context 'when veterinarian has no work schedule' do
      let!(:locality) { create(:locality) }
      let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
      let!(:certification_request) do
        create(:certification_request,
               locality: locality,
               preferred_time_range: (Time.parse('2024-12-02 09:00:00 UTC')..Time.parse('2024-12-02 11:00:00 UTC')))
      end

      before do
        # Setup vet to serve the same locality
        vet_profile.vet_service_areas.first.update!(locality: locality)
        # Remove work schedule
        vet_profile.vet_work_schedule.destroy!
      end

      it 'the certification requests do not add any vet_profile' do
        certification_request_handled = described_class.new(certification_request:).call!

        expect(certification_request_handled.vet_profile).to be_nil
      end
    end

    context 'when veterinarian has conflicting appointments' do
      let!(:locality) { create(:locality) }
      let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
      let!(:certification_request) do
        create(:certification_request,
               locality: locality,
               preferred_time_range: (Time.parse('2024-12-02 09:00:00 UTC')..Time.parse('2024-12-02 11:00:00 UTC')))
      end

      before do
        # Setup vet to serve the same locality
        vet_profile.vet_service_areas.first.update!(locality: locality)
        # Setup vet to work on Monday mornings
        vet_profile.vet_work_schedule.update!(monday: 'morning')
        # Create conflicting appointment
        create(:certification_request,
               vet_profile: vet_profile,
               scheduled_date: Date.parse('2024-12-02'),
               status: 'assigned')
      end

      it 'the certification requests do not add any vet_profile' do
        certification_request_handled = described_class.new(certification_request:).call!

        expect(certification_request_handled.vet_profile).to be_nil
      end
    end

    context 'with different work schedules' do
      context 'when vet works afternoon only' do
        let!(:locality) { create(:locality) }
        let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
        let!(:certification_request) do
          create(:certification_request,
                 locality: locality,
                 preferred_time_range: (Time.parse('2024-12-02 14:00:00 UTC')..Time.parse('2024-12-02 17:00:00 UTC')))
        end

        before do
          # Setup vet to serve the same locality
          vet_profile.vet_service_areas.first.update!(locality: locality)
          # Setup vet to work on Monday afternoons
          vet_profile.vet_work_schedule.update!(monday: 'afternoon')
        end

        it 'assigns veterinarian for afternoon schedule' do
          service = described_class.new(certification_request: certification_request)

          result = service.call!

          expect(result.scheduled_time).to eq('afternoon')
        end
      end

      context 'when vet works both morning and afternoon' do
        let!(:locality) { create(:locality) }
        let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }

        before do
          # Setup vet to serve the same locality
          vet_profile.vet_service_areas.first.update!(locality: locality)
          # Setup vet to work on Monday both morning and afternoon
          vet_profile.vet_work_schedule.update!(monday: 'both')
        end

        it 'chooses morning for morning preferred time' do
          morning_request = create(
            :certification_request,
            locality: locality,
            preferred_time_range: (Time.parse('2024-12-02 09:00:00 UTC')..Time.parse('2024-12-02 11:00:00 UTC'))
          )
          service = described_class.new(certification_request: morning_request)

          result = service.call!

          expect(result.scheduled_time).to eq('morning')
        end

        it 'chooses afternoon for afternoon preferred time' do
          afternoon_request = create(
            :certification_request,
            locality: locality,
            preferred_time_range: (Time.parse('2024-12-02 14:00:00 UTC')..Time.parse('2024-12-02 16:00:00 UTC'))
          )
          service = described_class.new(certification_request: afternoon_request)

          result = service.call!

          expect(result.scheduled_time).to eq('afternoon')
        end
      end
    end

    context 'when preferred time range spans multiple days' do
      let!(:locality) { create(:locality) }
      let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
      let!(:multi_day_request) do
        create(:certification_request,
               locality: locality,
               preferred_time_range: (Time.parse('2024-12-02 09:00:00 UTC')..Time.parse('2024-12-03 17:00:00 UTC')))
      end

      before do
        # Setup vet to serve the same locality
        vet_profile.vet_service_areas.first.update!(locality: locality)
        # Setup vet work schedule for different days
        vet_profile.vet_work_schedule.update!(monday: 'morning', tuesday: 'afternoon')
      end

      it 'finds first available slot' do
        service = described_class.new(certification_request: multi_day_request)

        result = service.call!

        expect(result.scheduled_date).to eq(Date.parse('2024-12-02'))
      end
    end

    context 'when update fails' do
      let!(:locality) { create(:locality) }
      let!(:vet_profile) { create(:vet_profile, :with_service_areas_and_schedule) }
      let!(:certification_request) do
        create(:certification_request,
               locality: locality,
               preferred_time_range: (Time.parse('2024-12-02 09:00:00 UTC')..Time.parse('2024-12-02 11:00:00 UTC')))
      end

      before do
        # Setup vet to serve the same locality
        vet_profile.vet_service_areas.first.update!(locality: locality)
        # Setup vet to work on Monday mornings
        vet_profile.vet_work_schedule.update!(monday: 'morning')
        # Mock update to fail
        allow(certification_request).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(certification_request))
      end

      it 'raises an error' do
        service = described_class.new(certification_request: certification_request)

        expect { service.call! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
