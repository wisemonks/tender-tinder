require "test_helper"

class ProcurementFilterScopeTest < ActiveSupport::TestCase
  test "returns all procurements when user filters are blank" do
    results = ProcurementFilterScope.new(user: users(:one)).apply

    assert_equal Procurement.order(:id).pluck(:id), results.order(:id).pluck(:id)
  end

  test "filters by keywords across searchable text" do
    ScraperSetting.set("keywords", "saulės, infrastruktūros", user: users(:one))

    results = ProcurementFilterScope.new(user: users(:one)).apply

    assert_equal [ procurements(:one).id, procurements(:two).id ].sort, results.pluck(:id).sort
  end

  test "filters by local labels mapped from settings values" do
    user = users(:one)
    ScraperSetting.set("status", "cft.status.evaluation", user: user)
    ScraperSetting.set("contract_type", "cft.contract.type.services", user: user)
    ScraperSetting.set("procedure", "cft.procedure.type.open", user: user)
    ScraperSetting.set("cpc_category", "7", user: user)

    results = ProcurementFilterScope.new(user: user).apply

    assert_equal [ procurements(:two) ], results.to_a
  end

  test "filters by publication date and estimated value range" do
    user = users(:one)
    ScraperSetting.set("publication_from_date", "2025-11-22", user: user)
    ScraperSetting.set("publication_to_date", "2025-11-22", user: user)
    ScraperSetting.set("estimated_value_min", "10000", user: user)

    results = ProcurementFilterScope.new(user: user).apply

    assert_equal [ procurements(:one) ], results.to_a
  end
end
