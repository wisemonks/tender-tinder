# 📧 SMTP Configuration Guide

Complete guide for setting up email delivery in Tender Tinder.

## Overview

Tender Tinder uses SMTP to send daily digest emails with new procurement opportunities. This guide covers setting up various email providers.

## Quick Start

1. Choose an SMTP provider (Gmail, SendGrid, Mailgun, etc.)
2. Get SMTP credentials from your provider
3. Configure environment variables in `.kamal/secrets`
4. Deploy and test

## Choosing an SMTP Provider

### Free Options (Good for Testing)

- **Gmail** - Free, 500 emails/day limit, requires app password
- **Outlook/Hotmail** - Free, basic usage limits

### Recommended for Production

- **SendGrid** - 100 emails/day free, then paid plans
- **Mailgun** - 100 emails/day free trial, then paid
- **Amazon SES** - $0.10 per 1000 emails, most cost-effective
- **Postmark** - Starts at $15/month, excellent deliverability

## Provider Setup Guides

### 1. Gmail (Free - Best for Testing)

**Pros:** Free, easy setup, reliable
**Cons:** 500 emails/day limit, requires 2FA

#### Setup Steps:

1. **Enable 2-Factor Authentication**
   - Go to [Google Account Security](https://myaccount.google.com/security)
   - Enable 2-Step Verification

2. **Create App Password**
   - Visit [App Passwords](https://myaccount.google.com/apppasswords)
   - Select "Mail" and your device
   - Copy the generated 16-character password

3. **Configure in Kamal**

   Add to `.kamal/secrets`:
   ```bash
   SMTP_ADDRESS=smtp.gmail.com
   SMTP_PORT=587
   SMTP_DOMAIN=gmail.com
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-16-char-app-password
   SMTP_AUTHENTICATION=plain
   SMTP_ENABLE_STARTTLS_AUTO=true
   MAILER_HOST=tendertinder.yourdomain.com
   MAILER_PROTOCOL=https
   ```

4. **Update deploy.yml**
   ```yaml
   env:
     secret:
       - RAILS_MASTER_KEY
       - SMTP_PASSWORD
     clear:
       SMTP_ADDRESS: smtp.gmail.com
       SMTP_PORT: 587
       SMTP_DOMAIN: gmail.com
       SMTP_USERNAME: your-email@gmail.com
       SMTP_AUTHENTICATION: plain
       SMTP_ENABLE_STARTTLS_AUTO: true
       MAILER_HOST: tendertinder.yourdomain.com
       MAILER_PROTOCOL: https
   ```

### 2. SendGrid (Recommended for Production)

**Pros:** Reliable, good free tier, excellent deliverability
**Cons:** Requires domain verification for best results

#### Setup Steps:

1. **Sign Up**
   - Create account at [SendGrid](https://sendgrid.com/)
   - Verify your email

2. **Create API Key**
   - Go to [Settings > API Keys](https://app.sendgrid.com/settings/api_keys)
   - Click "Create API Key"
   - Choose "Restricted Access" → "Mail Send" → "Full Access"
   - Copy the API key (you won't see it again!)

3. **Verify Domain (Optional but Recommended)**
   - Go to Settings > Sender Authentication
   - Follow domain verification steps
   - Add DNS records as instructed

4. **Configure in Kamal**

   Add to `.kamal/secrets`:
   ```bash
   SMTP_ADDRESS=smtp.sendgrid.net
   SMTP_PORT=587
   SMTP_DOMAIN=yourdomain.com
   SMTP_USERNAME=apikey
   SMTP_PASSWORD=SG.your-actual-api-key-here
   SMTP_AUTHENTICATION=plain
   SMTP_ENABLE_STARTTLS_AUTO=true
   MAILER_HOST=tendertinder.yourdomain.com
   MAILER_PROTOCOL=https
   ```

   Update `config/deploy.yml`:
   ```yaml
   env:
     secret:
       - RAILS_MASTER_KEY
       - SMTP_PASSWORD
     clear:
       SMTP_ADDRESS: smtp.sendgrid.net
       SMTP_PORT: 587
       SMTP_DOMAIN: yourdomain.com
       SMTP_USERNAME: apikey
       SMTP_AUTHENTICATION: plain
       SMTP_ENABLE_STARTTLS_AUTO: true
       MAILER_HOST: tendertinder.yourdomain.com
       MAILER_PROTOCOL: https
   ```

### 3. Mailgun

**Pros:** Powerful API, flexible pricing
**Cons:** Requires domain verification, more setup

#### Setup Steps:

1. **Sign Up**
   - Create account at [Mailgun](https://www.mailgun.com/)
   - Add and verify your domain

2. **Get SMTP Credentials**
   - Go to [Sending > Domain Settings](https://app.mailgun.com/app/sending/domains)
   - Select your domain
   - Find SMTP credentials section
   - Copy username and password

3. **Configure in Kamal**

   Add to `.kamal/secrets`:
   ```bash
   SMTP_ADDRESS=smtp.mailgun.org
   SMTP_PORT=587
   SMTP_DOMAIN=yourdomain.com
   SMTP_USERNAME=postmaster@yourdomain.com
   SMTP_PASSWORD=your-mailgun-password
   SMTP_AUTHENTICATION=plain
   SMTP_ENABLE_STARTTLS_AUTO=true
   MAILER_HOST=tendertinder.yourdomain.com
   MAILER_PROTOCOL=https
   ```

### 4. Amazon SES (Most Cost-Effective)

**Pros:** Extremely cheap ($0.10/1000 emails), highly scalable
**Cons:** Requires AWS account, starts in sandbox mode

#### Setup Steps:

1. **AWS Setup**
   - Log into [AWS Console](https://console.aws.amazon.com/)
   - Go to Amazon SES
   - Select your region (e.g., us-east-1)

2. **Verify Email or Domain**
   - Go to Verified Identities
   - Add your email or domain
   - Complete verification

3. **Create SMTP Credentials**
   - Go to SMTP Settings
   - Click "Create SMTP Credentials"
   - Download and save the credentials

4. **Request Production Access** (if needed)
   - By default, SES is in sandbox mode (limited sending)
   - Go to Account Dashboard
   - Request production access

5. **Configure in Kamal**

   Add to `.kamal/secrets`:
   ```bash
   SMTP_ADDRESS=email-smtp.us-east-1.amazonaws.com
   SMTP_PORT=587
   SMTP_DOMAIN=yourdomain.com
   SMTP_USERNAME=your-ses-smtp-username
   SMTP_PASSWORD=your-ses-smtp-password
   SMTP_AUTHENTICATION=plain
   SMTP_ENABLE_STARTTLS_AUTO=true
   MAILER_HOST=tendertinder.yourdomain.com
   MAILER_PROTOCOL=https
   ```

### 5. Postmark

**Pros:** Excellent deliverability, great support, simple API
**Cons:** No free tier, $15/month minimum

#### Setup Steps:

1. **Sign Up**
   - Create account at [Postmark](https://postmarkapp.com/)
   - Create a server

2. **Get Server Token**
   - Go to your server settings
   - Copy the Server API Token

3. **Configure in Kamal**

   Add to `.kamal/secrets`:
   ```bash
   SMTP_ADDRESS=smtp.postmarkapp.com
   SMTP_PORT=587
   SMTP_DOMAIN=yourdomain.com
   SMTP_USERNAME=your-postmark-server-token
   SMTP_PASSWORD=your-postmark-server-token
   SMTP_AUTHENTICATION=plain
   SMTP_ENABLE_STARTTLS_AUTO=true
   MAILER_HOST=tendertinder.yourdomain.com
   MAILER_PROTOCOL=https
   ```

## Deployment with SMTP Configuration

### Method 1: Environment Variables (Recommended)

1. **Update `.kamal/secrets`** with your chosen provider settings

2. **Update `config/deploy.yml`**:
   ```yaml
   env:
     secret:
       - RAILS_MASTER_KEY
       - SMTP_PASSWORD
     clear:
       SMTP_ADDRESS: smtp.sendgrid.net  # or your provider
       SMTP_PORT: 587
       SMTP_DOMAIN: yourdomain.com
       SMTP_USERNAME: your-username
       SMTP_AUTHENTICATION: plain
       SMTP_ENABLE_STARTTLS_AUTO: true
       MAILER_HOST: tendertinder.yourdomain.com
       MAILER_PROTOCOL: https
   ```

3. **Deploy**:
   ```bash
   kamal deploy
   ```

### Method 2: Rails Credentials (Alternative)

If you prefer using Rails encrypted credentials:

1. **Edit credentials**:
   ```bash
   EDITOR=nano rails credentials:edit
   ```

2. **Add SMTP settings**:
   ```yaml
   smtp:
     address: smtp.sendgrid.net
     port: 587
     domain: yourdomain.com
     username: apikey
     password: your-api-key
     authentication: plain
     enable_starttls_auto: true
   ```

3. **Update production.rb** to use credentials instead of ENV vars

## Testing Email Configuration

### Test from Rails Console

```bash
# Access production console
kamal console

# Test email delivery
ActionMailer::Base.smtp_settings
# Should show your SMTP configuration

# Send test email
ProcurementMailer.daily_digest(
  "test@example.com",
  Procurement.limit(5)
).deliver_now

# Check for errors
```

### Test with Rake Task

```bash
# Send daily digest manually
kamal app exec "rake scraper:send_daily_digest"

# Check logs for delivery
kamal app logs -f
```

### Local Testing

For local development, use letter_opener gem:

```ruby
# In Gemfile (development group)
gem 'letter_opener'

# In config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
```

Emails will open in your browser instead of sending.

## Troubleshooting

### Email Not Sending

1. **Check SMTP credentials**:
   ```bash
   kamal app exec "env | grep SMTP"
   ```

2. **Check logs**:
   ```bash
   kamal app logs -f | grep -i mail
   ```

3. **Test SMTP connection**:
   ```bash
   kamal console
   > Net::SMTP.start('smtp.sendgrid.net', 587) do |smtp|
   >   smtp.enable_starttls
   >   smtp.auth_login('apikey', 'your-password')
   > end
   ```

### Common Errors

#### "Authentication failed"
- Double-check username and password
- For Gmail, ensure you're using App Password, not account password
- For SendGrid, username must be exactly "apikey"

#### "Connection timeout"
- Check SMTP_PORT is correct (usually 587)
- Verify firewall allows outbound SMTP
- Try port 2525 as alternative

#### "Relay access denied"
- Ensure SMTP_DOMAIN matches your verified domain
- Check domain verification status with provider

#### Emails go to spam
- Set up SPF, DKIM, and DMARC records
- Verify domain with email provider
- Use a professional "from" address

### Check Delivery Status

Most providers offer delivery tracking:

- **SendGrid**: Activity Feed in dashboard
- **Mailgun**: Logs section
- **Amazon SES**: CloudWatch logs
- **Postmark**: Message streams

## Setting Email Recipients

After deployment, configure recipients:

1. **Via Web Interface**:
   - Go to `/settings`
   - Add comma-separated emails in "Naujienlaiškio gavėjai"
   - Click "Išsaugoti nustatymus"

2. **Via Console**:
   ```bash
   kamal console
   > ScraperSetting.set("digest_emails", "email1@example.com, email2@example.com")
   ```

## Security Best Practices

1. **Never commit SMTP passwords**
   - Use `.kamal/secrets` (excluded from git)
   - Or use Rails credentials (encrypted)

2. **Use API tokens instead of passwords** when available
   - SendGrid, Mailgun, Postmark all support this

3. **Enable STARTTLS**
   - Always set `SMTP_ENABLE_STARTTLS_AUTO: true`

4. **Restrict API key permissions**
   - Only grant "send email" permission

5. **Monitor usage**
   - Set up alerts for unusual activity
   - Review logs regularly

## Cost Comparison

| Provider | Free Tier | Price After | Best For |
|----------|-----------|-------------|----------|
| Gmail | 500/day | N/A | Testing |
| SendGrid | 100/day | $19.95/month (40k) | Small-Medium |
| Mailgun | Trial only | $35/month (50k) | Medium-Large |
| Amazon SES | None | $0.10 per 1000 | Large Scale |
| Postmark | None | $15/month (10k) | High Deliverability |

## Recommendations

- **Development/Testing**: Gmail
- **Small Production (<100 daily)**: SendGrid free tier
- **Medium Production**: SendGrid or Mailgun
- **Large Scale**: Amazon SES
- **Best Deliverability**: Postmark

## Need Help?

- Check provider documentation
- Review application logs: `kamal app logs -f`
- Test SMTP connection manually
- Open an issue on GitHub

---

**Happy Emailing! 📧**
