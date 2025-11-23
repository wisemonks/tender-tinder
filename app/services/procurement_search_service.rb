class ProcurementSearchService
  attr_reader :query, :limit

  def initialize(query:, limit: 20)
    @query = query
    @limit = limit
  end

  def search
    return Procurement.none if query.blank?

    # If query looks like an ID, prioritize exact match
    if query.match?(/^\d+$/)
      exact_match = Procurement.where(external_id: query).limit(1)
      return exact_match if exact_match.exists?
    end

    # Perform keyword search using pg_search
    Procurement.search_by_text(query).limit(limit)
  end
end
