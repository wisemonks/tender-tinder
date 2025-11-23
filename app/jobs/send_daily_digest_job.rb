class SendDailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    emails_string = ScraperSetting.get("digest_emails")

    # Skip if no emails are configured
    return if emails_string.blank?

    # Parse comma-separated emails and clean them
    emails = emails_string.split(",").map(&:strip).reject(&:blank?)
    return if emails.empty?

    # Get procurements from yesterday
    yesterday = Date.yesterday
    procurements = Procurement.where(
      "DATE(created_at) = ?", yesterday
    ).order(created_at: :desc)

    # Send email to each recipient
    emails.each do |email|
      ProcurementMailer.daily_digest(email, procurements).deliver_now
      Rails.logger.info "📧 Daily digest sent to #{email} with #{procurements.count} procurement(s)"
    end

    Rails.logger.info "✅ Daily digest sent to #{emails.count} recipient(s)"
  end
end
