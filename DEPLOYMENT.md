# 🚀 Deployment Guide

Complete guide for deploying Tender Tinder to production using Kamal.

## Pre-Deployment Checklist

### Server Requirements

- [ ] Linux server with Docker installed (Ubuntu 20.04+ recommended)
- [ ] Root or sudo access
- [ ] Public IP address
- [ ] Domain name (optional, for SSL)
- [ ] SSH access configured

### Required Services

- [ ] PostgreSQL database (external or via Kamal accessory)
- [ ] Redis instance (for Solid Queue)
- [ ] SMTP server (for email digest)
- [ ] Container registry (Docker Hub, GHCR, or local)

## Step-by-Step Deployment

### 1. Prepare Your Server

```bash
# SSH into your server
ssh root@your-server-ip

# Update system packages
apt update && apt upgrade -y

# Kamal will install Docker during setup
```

### 2. Configure Local Environment

```bash
# Clone the repository
git clone https://github.com/yourusername/tendertinder.git
cd tendertender

# Install Kamal
gem install kamal

# Ensure config/master.key exists
# This file is needed for Rails credentials
# Generate if missing: rails credentials:edit
```

### 3. Configure Deployment

Edit `config/deploy.yml`:

```yaml
service: tindertender
image: tindertender

servers:
  web:
    - YOUR_SERVER_IP  # Replace with actual IP

registry:
  # Option 1: Docker Hub
  server: hub.docker.com
  username: YOUR_DOCKER_USERNAME

  # Option 2: GitHub Container Registry
  # server: ghcr.io
  # username: YOUR_GITHUB_USERNAME

  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true
```

### 4. Configure Secrets

Edit `.kamal/secrets`:

```bash
# Rails master key (required)
RAILS_MASTER_KEY=$(cat config/master.key)

# Registry password
# For Docker Hub: use access token from https://hub.docker.com/settings/security
# For GHCR: use GitHub PAT with write:packages scope
KAMAL_REGISTRY_PASSWORD=your_registry_token_here
```

### 5. Setup Database

#### Option A: External PostgreSQL

Add to `config/deploy.yml`:

```yaml
env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
  clear:
    SOLID_QUEUE_IN_PUMA: true
```

Add to `.kamal/secrets`:

```bash
DATABASE_URL=postgres://user:password@db-host:5432/tindertender_production
```

#### Option B: Kamal Accessory (PostgreSQL on same server)

Uncomment in `config/deploy.yml`:

```yaml
accessories:
  db:
    image: postgres:16
    host: YOUR_SERVER_IP
    port: "127.0.0.1:5432:5432"
    env:
      clear:
        POSTGRES_DB: tindertender_production
        POSTGRES_USER: tindertender
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data

  redis:
    image: valkey/valkey:8
    host: YOUR_SERVER_IP
    port: 6379
    directories:
      - data:/data
```

Add to `.kamal/secrets`:

```bash
POSTGRES_PASSWORD=secure_random_password_here
```

### 6. Initial Deployment

```bash
# Setup server and install Docker
kamal setup

# If using Kamal accessories for database:
kamal accessory boot all

# Wait a moment for database to start
sleep 10

# Create and migrate database
kamal app exec "bin/rails db:create"
kamal app exec "bin/rails db:migrate"
kamal app exec "bin/rails db:seed"  # if you have seeds

# Deploy application
kamal deploy
```

### 7. Configure SSL (Optional but Recommended)

#### Update deploy.yml:

```yaml
proxy:
  ssl: true
  host: tendertinder.yourdomain.com
```

#### Update DNS:

Point your domain A record to your server IP:
```
tendertinder.yourdomain.com  →  YOUR_SERVER_IP
```

#### Update Rails config:

Add to `config/environments/production.rb`:

```ruby
config.assume_ssl = true
config.force_ssl = true
config.hosts << "tendertinder.yourdomain.com"
```

Redeploy:

```bash
kamal deploy
```

### 8. Configure Email (SMTP)

Email digest requires SMTP configuration. **See [SMTP_SETUP.md](SMTP_SETUP.md) for comprehensive provider guides.**

#### Quick Setup Example (SendGrid - Recommended):

1. **Get SendGrid API Key** from [SendGrid Dashboard](https://app.sendgrid.com/settings/api_keys)

2. **Add to `.kamal/secrets`**:
   ```bash
   SMTP_PASSWORD=SG.your-sendgrid-api-key
   ```

3. **Update `config/deploy.yml`**:
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

#### Other Providers:

See detailed setup guides in [SMTP_SETUP.md](SMTP_SETUP.md):
- **Gmail** (Free) - Best for testing, 500 emails/day limit
- **Amazon SES** - Most cost-effective for production ($0.10/1000 emails)
- **Mailgun** - Flexible pricing, powerful features
- **Postmark** - Best deliverability, $15/month

#### Test Email Setup:

```bash
# Send test digest
kamal app exec "rake scraper:send_daily_digest"

# Check logs
kamal app logs -f | grep -i mail
```

### 9. Initialize Application

```bash
# Access the application console
kamal console

# In the Rails console:
ScraperSetting.initialize_defaults
exit

# Or access via web interface at:
# https://tendertinder.yourdomain.com/settings
```

### 10. Test Everything

- [ ] Visit your application URL
- [ ] Check `/settings` page loads
- [ ] Configure email recipients in settings
- [ ] Run manual scrape: `kamal app exec "bin/rails runner 'ScrapeListJob.perform_now(page: 1, max_pages: 1)'"`
- [ ] Check logs: `kamal app logs -f`
- [ ] Verify email digest works: `kamal app exec "rake scraper:send_daily_digest"`

## Post-Deployment

### Monitoring

```bash
# View live logs
kamal app logs -f

# Check application status
kamal app details

# View container stats
kamal app exec "ps aux"
```

### Backups

Set up regular PostgreSQL backups:

```bash
# Add cron job on server or use managed database backups
pg_dump -h localhost -U tindertender tindertender_production > backup.sql
```

### Updates

```bash
# Pull latest changes
git pull origin main

# Deploy update
kamal deploy

# If database changes:
kamal app exec "bin/rails db:migrate"
```

### Scaling

#### Multiple Web Servers:

```yaml
servers:
  web:
    - 192.168.0.1
    - 192.168.0.2
```

#### Dedicated Job Server:

```yaml
servers:
  web:
    - 192.168.0.1
  job:
    hosts:
      - 192.168.0.2
    cmd: bin/jobs
```

Update env:

```yaml
env:
  clear:
    # Remove for dedicated job server
    # SOLID_QUEUE_IN_PUMA: true
```

## Troubleshooting

### Deployment fails

```bash
# Check server connectivity
kamal audit

# Verify Docker is running
kamal app exec "docker ps"

# Check registry login
docker login hub.docker.com
```

### Application won't start

```bash
# Check logs
kamal app logs -f

# Verify environment variables
kamal app exec "env | grep RAILS"

# Check database connection
kamal app exec "bin/rails runner 'puts ActiveRecord::Base.connection.active?'"
```

### Database connection errors

```bash
# If using accessory, check if running
kamal accessory details db

# Test database connection
kamal app exec "bin/rails dbconsole"

# Check DATABASE_URL
kamal app exec "echo $DATABASE_URL"
```

### SSL certificate issues

```bash
# Check proxy status
kamal proxy details

# Restart proxy
kamal proxy reboot

# Verify DNS points to server
dig tendertinder.yourdomain.com
```

## Useful Commands

```bash
# View all running containers
kamal details

# Access Rails console
kamal console

# Run rake task
kamal app exec "rake scraper:scrape_procurements"

# Database console
kamal dbc

# SSH into server
kamal shell

# Restart application
kamal app boot

# Rollback deployment
kamal rollback VERSION

# Complete removal
kamal remove
```

## Performance Tuning

### Increase Workers

```yaml
env:
  clear:
    WEB_CONCURRENCY: 3      # Puma workers
    JOB_CONCURRENCY: 5       # Solid Queue workers
```

### Optimize Database

```bash
# Add indexes for frequently queried columns
kamal app exec "bin/rails dbconsole"
> CREATE INDEX CONCURRENTLY idx_procurements_title ON procurements USING gin(to_tsvector('simple', title));
```

### Enable Caching

Update `config/environments/production.rb`:

```ruby
config.cache_store = :solid_cache_store
```

## Security Checklist

- [ ] Change default database password
- [ ] Use strong RAILS_MASTER_KEY
- [ ] Enable SSL/HTTPS
- [ ] Configure firewall (allow 80, 443, 22)
- [ ] Regular security updates
- [ ] Restrict SSH access
- [ ] Use SSH keys instead of passwords
- [ ] Enable fail2ban for SSH protection

## Support

- Check [README.md](README.md) for general information
- Review [Kamal documentation](https://kamal-deploy.org/)
- Open an issue on GitHub for help

---

**Happy Deploying! 🔥**
