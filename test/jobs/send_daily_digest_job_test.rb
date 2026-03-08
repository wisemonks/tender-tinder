require "test_helper"

class SendDailyDigestJobTest < ActiveJob::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "sends to unique valid recipients for yesterday's filtered procurements" do
    travel_to Time.zone.local(2025, 11, 23, 10, 0, 0) do
      user = users(:one)

      ScraperSetting.set(
        "digest_emails",
        "alerts@example.com, invalid-email, alerts@example.com, second@example.com",
        user: user
      )
      ScraperSetting.set("keywords", "infrastruktūros", user: user)

      yesterday_procurement = Procurement.create!(
        external_id: "2001",
        title: "Vakarykštis pirkimas",
        description: "Svarbus infrastruktūros atnaujinimas",
        created_at: 1.day.ago,
        updated_at: 1.day.ago
      )

      Procurement.create!(
        external_id: "2002",
        title: "Šiandienos pirkimas",
        description: "Dar vienas aktualus pirkimas",
        created_at: Time.current,
        updated_at: Time.current
      )

      Procurement.create!(
        external_id: "2003",
        title: "Vakarykštė, bet nesutampanti frazė",
        description: "Neraktinis tekstas",
        created_at: 1.day.ago,
        updated_at: 1.day.ago
      )

      assert_difference -> { ActionMailer::Base.deliveries.size }, 2 do
        SendDailyDigestJob.perform_now(user_id: user.id)
      end

      recipients = ActionMailer::Base.deliveries.flat_map(&:to)
      bodies = ActionMailer::Base.deliveries.map { |mail| mail.html_part.body.decoded }

      assert_equal [ "alerts@example.com", "second@example.com" ], recipients.sort
      assert bodies.all? { |body| body.include?(yesterday_procurement.title) }
      assert bodies.none? { |body| body.include?("Šiandienos pirkimas") }
      assert bodies.none? { |body| body.include?("Vakarykštė, bet nesutampanti frazė") }
    end
  end

  test "does nothing when no valid recipients are configured" do
    ScraperSetting.set("digest_emails", "invalid-email", user: users(:one))

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      SendDailyDigestJob.perform_now(user_id: users(:one).id)
    end
  end
end
