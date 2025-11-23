require "test_helper"

class ProcurementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get procurements_index_url
    assert_response :success
  end

  test "should get show" do
    get procurements_show_url
    assert_response :success
  end

  test "should get toggle_starred" do
    get procurements_toggle_starred_url
    assert_response :success
  end
end
