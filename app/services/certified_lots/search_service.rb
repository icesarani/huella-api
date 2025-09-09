# frozen_string_literal: true

module CertifiedLots
  class SearchService
    # Retrieves all certified lots
    # @return [ActiveRecord::Relation<CertifiedLot>] All certified lots
    def call
      CertifiedLot.all
    end
  end
end
