require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "should get show" do
    get settings_url
    assert_response :success
  end

  test "should redirect guests to sign in" do
    sign_out users(:one)

    get settings_url

    assert_redirected_to new_user_session_url
  end

  test "should update settings" do
    patch settings_url, params: {
      settings: {
        keywords: "saulės elektrinė, IT priežiūra",
        status: "cft.status.award",
        digest_emails: "new@example.com"
      }
    }

    assert_redirected_to settings_url
    assert_equal "saulės elektrinė, IT priežiūra", ScraperSetting.get("keywords", user: users(:one))
    assert_equal "cft.status.award", ScraperSetting.get("status", user: users(:one))
    assert_equal "new@example.com", ScraperSetting.get("digest_emails", user: users(:one))
  end
end
