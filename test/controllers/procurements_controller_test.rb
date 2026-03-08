require "test_helper"

class ProcurementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "should get index" do
    get procurements_url
    assert_response :success
  end

  test "should redirect guests to sign in" do
    sign_out users(:one)

    get procurements_url

    assert_redirected_to new_user_session_url
    follow_redirect!
    assert_includes response.body, "Norėdami tęsti, prisijunkite arba susikurkite paskyrą."
  end


  test "should show only filtered procurements" do
    ScraperSetting.set("status", "cft.status.evaluation", user: users(:one))

    get procurements_url

    assert_response :success
    assert_includes response.body, procurements(:two).title
    assert_not_includes response.body, procurements(:one).title
  end

  test "should get show" do
    get procurement_url(procurements(:one))
    assert_response :success
  end

  test "should search within procurements" do
    get procurements_url, params: { query: procurements(:one).external_id }

    assert_response :success
    assert_includes response.body, procurements(:one).title
    assert_not_includes response.body, procurements(:two).title
  end

  test "should toggle starred with html redirect" do
    procurement = procurements(:one)

    assert_not procurement.starred_by?(users(:one))

    post toggle_starred_procurement_url(procurement)

    assert_redirected_to procurement_url(procurement)
    assert procurement.reload.starred_by?(users(:one))
  end

  test "should toggle starred with json" do
    procurement = procurements(:two)

    post toggle_starred_procurement_url(procurement), as: :json

    assert_response :success
    assert_equal false, JSON.parse(response.body)["is_starred"]
    assert_not procurement.reload.starred_by?(users(:one))
  end
end
