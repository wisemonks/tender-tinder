require "test_helper"

class ProcurementTest < ActiveSupport::TestCase
  test "toggle_starred_for! flips the user star relation" do
    procurement = procurements(:one)
    user = users(:one)

    assert_not procurement.starred_by?(user)

    procurement.toggle_starred_for!(user)

    assert procurement.reload.starred_by?(user)
  end

  test "detail_url prefers stored url" do
    procurement = procurements(:one)

    assert_equal "https://example.com/procurements/1001", procurement.detail_url
  end

  test "detail_url falls back to generated url" do
    procurement = procurements(:one).dup
    procurement.url = nil

    assert_equal(
      "https://viesiejipirkimai.lt/epps/cft/prepareViewCfTWS.do?resourceId=1001",
      procurement.detail_url
    )
  end
end
