require "test_helper"

class ProcurementMailerTest < ActionMailer::TestCase
  test "daily_digest" do
    mail = ProcurementMailer.daily_digest("to@example.org", [ procurements(:one) ])

    assert_includes mail.subject, "Tender Tinder"
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_includes mail.html_part.body.decoded, procurements(:one).title
  end
end
