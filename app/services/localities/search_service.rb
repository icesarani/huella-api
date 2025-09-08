# frozen_string_literal: true

module Localities
  class SearchService
    # Fetches all localities ordered by name.
    # @return [ActiveRecord::Relation<Locality>]
    def call
      Locality.order(:name)
    end
  end
end
