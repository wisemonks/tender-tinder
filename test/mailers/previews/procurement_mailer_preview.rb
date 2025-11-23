# Preview all emails at http://localhost:3000/rails/mailers/procurement_mailer
class ProcurementMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/procurement_mailer/daily_digest
  def daily_digest
    ProcurementMailer.daily_digest
  end
end
