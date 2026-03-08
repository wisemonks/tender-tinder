class SendDailyDigestJob < ApplicationJob
  VALID_EMAIL = URI::MailTo::EMAIL_REGEXP

  queue_as :default

  def perform(user_id: nil)
    if user_id
      send_digest_for(User.find_by(id: user_id))
    else
      User.find_each { |user| send_digest_for(user) }
    end
  end

  private

  def send_digest_for(user)
    return unless user

    emails = recipient_emails(user)
    return if emails.empty?

    procurements = procurements_for_digest(user)
    procurement_count = procurements.size

    emails.each do |email|
      ProcurementMailer.daily_digest(email, procurements).deliver_now
      Rails.logger.info "📧 Daily digest sent to #{email} with #{procurement_count} procurement(s)"
    end

    Rails.logger.info "✅ Daily digest sent to #{emails.count} recipient(s)"
  end

  def recipient_emails(user)
    ScraperSetting.get("digest_emails", user: user)
      .to_s
      .split(",")
      .map(&:strip)
      .reject(&:blank?)
      .select { |email| email.match?(VALID_EMAIL) }
      .uniq
  end

  def procurements_for_digest(user)
    user.filtered_procurements(scope: Procurement.where(created_at: Time.zone.yesterday.all_day))
      .order(created_at: :desc)
  end
end
