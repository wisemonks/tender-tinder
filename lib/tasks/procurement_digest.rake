namespace :procurement do
  desc "Send daily digest email with new procurements"
  task send_digest: :environment do
    emails_string = ScraperSetting.get("digest_emails")

    if emails_string.blank?
      puts "❌ Email addresses not configured!"
      puts "Please set the email addresses (comma-separated):"
      puts "  ScraperSetting.set('digest_emails', 'email1@example.com, email2@example.com', description: 'El. pašto adresai naujienlaiškiui (atskirti kableliais)', setting_type: 'text')"
      exit
    end

    # Parse comma-separated emails
    emails = emails_string.split(",").map(&:strip).reject(&:blank?)

    if emails.empty?
      puts "❌ No valid email addresses found!"
      exit
    end

    puts "📧 Sending daily digest to: #{emails.join(', ')}"
    puts "=" * 80

    # Get procurements from yesterday
    yesterday = Date.yesterday
    procurements = Procurement.where(
      "DATE(created_at) = ?", yesterday
    ).order(created_at: :desc)

    puts "Found #{procurements.count} procurement(s) from #{yesterday}"

    if procurements.any?
      puts "\nProcurements:"
      procurements.each_with_index do |p, i|
        puts "  #{i + 1}. #{p.title} (#{p.external_id})"
      end
    end

    puts "\n📤 Sending emails..."
    emails.each do |email|
      ProcurementMailer.daily_digest(email, procurements).deliver_now
      puts "  ✓ Sent to #{email}"
    end

    puts "✅ Emails sent successfully to #{emails.count} recipient(s)!"
    puts "=" * 80
  end

  desc "Test daily digest with all procurements (for testing)"
  task test_digest: :environment do
    emails_string = ScraperSetting.get("digest_emails")

    if emails_string.blank?
      puts "❌ Email addresses not configured!"
      puts "Please set: ScraperSetting.set('digest_emails', 'email1@example.com, email2@example.com')"
      exit
    end

    # Parse comma-separated emails
    emails = emails_string.split(",").map(&:strip).reject(&:blank?)

    if emails.empty?
      puts "❌ No valid email addresses found!"
      exit
    end

    puts "📧 Sending TEST digest to: #{emails.join(', ')}"
    puts "=" * 80

    # Get recent procurements for testing
    procurements = Procurement.order(created_at: :desc).limit(10)

    puts "Found #{procurements.count} recent procurement(s)"
    puts "\n📤 Sending test emails..."

    emails.each do |email|
      ProcurementMailer.daily_digest(email, procurements).deliver_now
      puts "  ✓ Sent to #{email}"
    end

    puts "✅ Test emails sent successfully to #{emails.count} recipient(s)!"
    puts "=" * 80
  end
end
