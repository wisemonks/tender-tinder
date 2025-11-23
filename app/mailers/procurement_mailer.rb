class ProcurementMailer < ApplicationMailer
  def daily_digest(email, procurements)
    @procurements = procurements
    @date = Date.yesterday

    mail(
      to: email,
      subject: "🔥 Tender Tinder - Nauji pirkimai (#{@date.strftime('%Y-%m-%d')})"
    )
  end
end
