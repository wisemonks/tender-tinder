<div align="center">

# 🔥 Tender Tinder

<img src="https://raw.githubusercontent.com/icons8/flat-color-icons/master/svg/fire-element.svg" width="150" height="150" alt="Tender Tinder Logo">

**Swipe right on the perfect tender!**

A modern Rails 8.1 application for scraping, storing, and searching Lithuanian public procurement data from [viesiejipirkimai.lt](https://viesiejipirkimai.lt).

[![Rails](https://img.shields.io/badge/Rails-8.1.2-red.svg)](https://rubyonrails.org/)
[![Ruby](https://img.shields.io/badge/Ruby-3.4+-red.svg)](https://www.ruby-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Deployed with Kamal](https://img.shields.io/badge/Deployed%20with-Kamal-blue.svg)](https://kamal-deploy.org/)

[Features](#-features) • [Quick Start](#-quick-start) • [Deployment](#-deployment-with-kamal) • [Configuration](#-configuration)

</div>

---

## ✨ Features

- 🔍 **Full-Text Search** - Powerful PostgreSQL-based search with trigram matching
- 🤖 **Automated Scraping** - Daily procurement data collection from viesiejipirkimai.lt
- ⭐ **Starred Procurements** - Mark and organize interesting tenders
- 🔐 **User Authentication** - Secure sign up, sign in, and session management with Devise
- 📧 **Email Digest** - Daily notifications for new procurement opportunities
- 🎨 **Modern UI** - Beautiful TailwindCSS interface with real-time updates via Turbo
- 🚀 **Background Jobs** - Efficient processing with Solid Queue
- 🐳 **Docker Ready** - Deploy anywhere with Kamal in minutes

## 🏗️ Tech Stack

- **Framework**: Rails 8.1.2
- **Database**: PostgreSQL with pg_trgm extension
- **Background Jobs**: Solid Queue (database-backed)
- **Frontend**: TailwindCSS + Turbo + Stimulus
- **Scraping**: Nokogiri + Faraday
- **Search**: pg_search (full-text + trigram)
- **Deployment**: Kamal 2.0 + Docker

## 🚀 Quick Start

### Prerequisites

- Ruby 3.4+ (specified in `.ruby-version`)
- PostgreSQL 13+
- Redis (for Solid Queue)
- Docker (for deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tendertinder.git
   cd tendertender
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create db:migrate
   ```

4. **Start the application**
   ```bash
   # Start all services with foreman
   bin/dev

   # Or start separately:
   bin/rails server  # Rails server
   bin/jobs          # Solid Queue worker
   ```

5. **Visit the application**

   Open [http://localhost:3000](http://localhost:3000) and sign up for an account at `/users/sign_up`.

### Run Your First Scrape

```bash
# Scrape recent procurements (first 5 pages in development)
rake scraper:scrape_procurements

# Or via Rails console
rails console
ScrapeListJob.perform_now(page: 1, max_pages: 5)
```

## 🚢 Deployment with Kamal

Tender Tinder is designed for seamless deployment using [Kamal](https://kamal-deploy.org/), the official Rails deployment tool. Deploy to any Linux server with Docker in minutes!

### Initial Setup

1. **Install Kamal** (if not already installed)
   ```bash
   gem install kamal
   ```

2. **Configure your deployment**

   Edit `config/deploy.yml`:
   ```yaml
   service: tindertender
   image: tindertender

   servers:
     web:
       - 192.168.0.1  # Replace with your server IP

   registry:
     server: localhost:5555  # Or use hub.docker.com, ghcr.io, etc.
     username: your-username
     password:
       - KAMAL_REGISTRY_PASSWORD

   env:
     secret:
       - RAILS_MASTER_KEY
     clear:
       SOLID_QUEUE_IN_PUMA: true
   ```

3. **Setup secrets**

   Edit `.kamal/secrets`:
   ```bash
   # Use your actual Rails master key
   RAILS_MASTER_KEY=$(cat config/master.key)

   # If using external registry
   KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
   ```

### Deploy Commands

```bash
# First-time setup (installs Docker, prepares server)
kamal setup

# Deploy application
kamal deploy

# View logs
kamal app logs -f

# Access Rails console on production
kamal console

# Access server shell
kamal shell

# Database console
kamal dbc
```

### Database Setup for Production

You have two options:

#### Option 1: External PostgreSQL Server

Configure in `config/deploy.yml`:
```yaml
env:
  clear:
    DB_HOST: your-postgres-server.com
    DATABASE_URL: postgres://user:password@your-postgres-server.com/tindertender_production
```

#### Option 2: Kamal Database Accessory

Uncomment the db accessory in `config/deploy.yml`:
```yaml
accessories:
  db:
    image: postgres:16
    host: 192.168.0.1
    port: "127.0.0.1:5432:5432"
    env:
      clear:
        POSTGRES_DB: tindertender_production
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data

  redis:
    image: valkey/valkey:8
    host: 192.168.0.1
    port: 6379
    directories:
      - data:/data
```

Add to `.kamal/secrets`:
```bash
POSTGRES_PASSWORD=your_secure_password
```

Setup accessories:
```bash
kamal accessory boot db
kamal accessory boot redis
```

### SSL/HTTPS with Let's Encrypt

Enable automatic SSL in `config/deploy.yml`:
```yaml
proxy:
  ssl: true
  host: tendertinder.yourdomain.com
```

Update `config/environments/production.rb`:
```ruby
config.assume_ssl = true
config.force_ssl = true
```

### Running Migrations

```bash
# Run migrations on deployment
kamal app exec "bin/rails db:migrate"

# Or add to deploy hooks in .kamal/hooks/post-deploy
```

### Email Configuration (SMTP)

The daily digest feature requires SMTP configuration. See **[SMTP_SETUP.md](SMTP_SETUP.md)** for detailed provider guides.

**Quick Example (SendGrid)**:

Edit `config/deploy.yml`:
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
    MAILER_HOST: tendertinder.yourdomain.com
```

Add to `.kamal/secrets`:
```bash
SMTP_PASSWORD=SG.your-sendgrid-api-key
```

**Supported Providers:**
- Gmail (free, great for testing)
- SendGrid (recommended for production)
- Amazon SES (most cost-effective)
- Mailgun, Postmark, and more

See [SMTP_SETUP.md](SMTP_SETUP.md) for complete setup instructions for each provider.

After deployment, configure email recipients at `/settings`.

### Monitoring & Maintenance

```bash
# View application logs
kamal app logs -f

# Check running containers
kamal app details

# Restart application
kamal app boot

# Rollback to previous version
kamal rollback [VERSION]

# Remove everything (caution!)
kamal remove
```

## ⚙️ Configuration

### Application Settings

Access settings at `/settings` after deployment:

- **Max Pages**: Number of pages to scrape (default: 100)
- **Scraping Enabled**: Toggle automatic scraping
- **Email Recipients**: Comma-separated emails for daily digest
- **Scraping Delay**: Delay between requests (seconds)

### Scheduled Jobs

Configure in `config/recurring.yml`:

```yaml
production:
  scrape_procurements:
    class: ScrapeListJob
    queue: default
    schedule: every day at 2am

  send_daily_digest:
    class: SendDailyDigestJob
    queue: default
    schedule: every day at 8am
```

### Manual Tasks

```bash
# Scrape procurements
rake scraper:scrape_procurements

# Send daily digest
rake scraper:send_daily_digest

# Via console
kamal console
> ScrapeListJob.perform_now(page: 1, max_pages: 10)
```

## 📖 Architecture

### Models

- **Procurement** - Main procurement record with metadata
- **ScraperSetting** - Configuration settings

### Services

- **Scrapers::PublicProcurementService** - Web scraping logic
- **ProcurementSearchService** - Full-text search implementation

### Jobs

- **ScrapeListJob** - Scrapes procurement list pages
- **ScrapeDetailJob** - Scrapes individual details
- **SendDailyDigestJob** - Sends email notifications

### Search Capabilities

- Full-text search with PostgreSQL tsearch
- Trigram fuzzy matching for similar terms
- Exact ID lookup for direct access

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Ruby on Rails 8.1](https://rubyonrails.org/)
- Deployed with [Kamal](https://kamal-deploy.org/)
- Data sourced from [viesiejipirkimai.lt](https://viesiejipirkimai.lt)
- Icons by [Icons8](https://icons8.com/)

---

<div align="center">

**Made with 🔥 by the Tender Tinder community**

</div>
