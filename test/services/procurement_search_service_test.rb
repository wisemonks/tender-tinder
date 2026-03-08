require "test_helper"

class ProcurementSearchServiceTest < ActiveSupport::TestCase
  test "returns exact match within scope for numeric query" do
    scope = Procurement.where(id: procurements(:one).id)

    results = ProcurementSearchService.new(query: procurements(:one).external_id, scope: scope).search

    assert_equal [ procurements(:one) ], results.to_a
  end

  test "respects the provided scope for keyword queries" do
    scope = Procurement.where(id: procurements(:two).id)

    results = ProcurementSearchService.new(query: "savivaldybė", scope: scope).search

    assert_equal [ procurements(:two) ], results.to_a
  end
end
