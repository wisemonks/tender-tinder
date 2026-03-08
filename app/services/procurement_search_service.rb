class ProcurementSearchService
  attr_reader :query, :scope

  def initialize(query:, scope: Procurement.all)
    @query = query
    @scope = scope
  end

  def search
    return scope.none if query.blank?

    # If query looks like an ID, prioritize exact match
    if query.match?(/^\d+$/)
      exact_match = scope.where(external_id: query).limit(1)
      return exact_match if exact_match.exists?
    end

    # Perform keyword search using pg_search
    scope.where(id: Procurement.search_by_text(query).select(:id))
  end
end
