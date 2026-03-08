require "test_helper"

class ScraperSettingTest < ActiveSupport::TestCase
  test "initialize_defaults backfills all expected settings" do
    user = users(:one)
    user.scraper_settings.delete_all

    assert_difference(-> { user.scraper_settings.count }, ScraperSetting::DEFAULTS.size) do
      ScraperSetting.initialize_defaults(user: user)
    end

    assert_equal "date", user.scraper_settings.find_by!(key: "publication_from_date").setting_type
    assert_equal "number", user.scraper_settings.find_by!(key: "estimated_value_min").setting_type
  end

  test "set preserves existing setting type" do
    setting = scraper_settings(:status)

    ScraperSetting.set(setting.key, "cft.status.award", user: setting.user)

    assert_equal "select", setting.reload.setting_type
    assert_equal "cft.status.award", setting.value
  end
end
