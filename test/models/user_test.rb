require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixture user is valid" do
    assert users(:one).valid?
  end


  test "filtered_procurements use current settings" do
    ScraperSetting.set("status", "cft.status.evaluation", user: users(:one))

    assert_equal [ procurements(:two) ], users(:one).filtered_procurements.to_a
  end

  test "new users get default scraper settings" do
    assert_difference(-> { ScraperSetting.count }, ScraperSetting::DEFAULTS.size) do
      User.create!(
        email: "fresh@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end
  end
end
