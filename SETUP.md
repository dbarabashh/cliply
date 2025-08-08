# Cliply Development Setup Guide

## Prerequisites

- Docker and Docker Compose installed
- Ruby 3.4.3 (for local development without Docker)
- Node.js 20+ and pnpm (for frontend development)
- PostgreSQL client tools (optional, for database management)

## Quick Start with Docker

### 1. Clone the repository
```bash
git clone <repository-url>
cd cliply
```

### 2. Set up environment variables
```bash
cp .env.example .env
# Edit .env with your specific configuration
```

### 3. Start all services with Docker Compose
```bash
docker-compose up -d
```

This will start:
- PostgreSQL database (port 5432)
- Redis (port 6379)
- Rails API backend (port 3000)
- Sidekiq background worker

### 4. Set up the database
```bash
# Create both development and test databases
docker-compose exec backend rails db:create

# Run migrations (this will also enable PostgreSQL extensions)
docker-compose exec backend rails db:migrate

# Prepare test database
docker-compose exec backend rails db:test:prepare

# (Optional) Seed the database with sample data
docker-compose exec backend rails db:seed
```

### 5. Install frontend dependencies
```bash
cd frontend
pnpm install
pnpm dev
```

The application will be available at:
- Frontend: http://localhost:5173
- Backend API: http://localhost:3000
- PostgreSQL: localhost:5432
- Redis: localhost:6379

## Docker Commands

### Start services
```bash
docker-compose up        # Start all services (attached)
docker-compose up -d     # Start all services (detached)
```

### Stop services
```bash
docker-compose down      # Stop all services
docker-compose down -v   # Stop and remove volumes (WARNING: deletes data)
```

### View logs
```bash
docker-compose logs -f          # All services
docker-compose logs -f backend   # Rails backend only
docker-compose logs -f postgres  # PostgreSQL only
docker-compose logs -f sidekiq   # Sidekiq only
```

### Access Rails console
```bash
docker-compose exec backend rails console
```

### Run Rails commands
```bash
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:seed
docker-compose exec backend bundle install
docker-compose exec backend rspec  # Run tests
```

### Access PostgreSQL
```bash
docker-compose exec postgres psql -U cliply -d cliply_development
```

## Local Development (without Docker)

If you prefer to run Rails locally without Docker:

### 1. Install PostgreSQL and Redis
```bash
# macOS with Homebrew
brew install postgresql@15 redis
brew services start postgresql@15
brew services start redis

# Ubuntu/Debian
sudo apt-get install postgresql-15 postgresql-client-15 redis-server
sudo systemctl start postgresql
sudo systemctl start redis
```

### 2. Set up environment variables
```bash
cp .env.example .env
# Edit .env and set DATABASE_HOST=localhost
```

### 3. Install Ruby dependencies
```bash
cd backend
bundle install
```

### 4. Set up the database
```bash
cd backend
# Create both development and test databases
rails db:create

# Run migrations (this will also enable PostgreSQL extensions)
rails db:migrate

# Prepare test database
rails db:test:prepare

# (Optional) Seed with sample data
rails db:seed
```

### 5. Start the Rails server
```bash
cd backend
rails server
```

### 6. Start Sidekiq (in a separate terminal)
```bash
cd backend
bundle exec sidekiq
```

## Database Management

### PostgreSQL Extensions
The Rails migrations automatically enable these PostgreSQL extensions:
- **uuid-ossp**: UUID generation for secure, unique identifiers
- **pg_trgm**: Trigram support for fuzzy text searching
- **pgcrypto**: Cryptographic functions for secure tokens

These are enabled via the migration `001_enable_postgres_extensions.rb`.

### Reset database
```bash
docker-compose exec backend rails db:reset
# Or locally:
cd backend && rails db:reset
```

### Create a new migration
```bash
docker-compose exec backend rails generate migration AddFieldToModel field:type
# Or locally:
cd backend && rails generate migration AddFieldToModel field:type
```

### Access database console
```bash
# With Docker
docker-compose exec postgres psql -U cliply -d cliply_development

# Locally
psql -U cliply -d cliply_development -h localhost
```

## Troubleshooting

### Port already in use
If you get a "port already in use" error:
```bash
# Find and kill the process using the port
lsof -i :3000  # or :5432 for PostgreSQL
kill -9 <PID>
```

### Database connection issues
1. Ensure PostgreSQL is running:
```bash
docker-compose ps
# Or locally:
pg_isready -h localhost -p 5432
```

2. Check your database configuration in `backend/config/database.yml`
3. Verify environment variables in `.env`

### Permission issues with Docker
If you encounter permission issues:
```bash
# Reset ownership of files
sudo chown -R $USER:$USER .
```

### Bundle install fails in Docker
```bash
# Rebuild the Docker image
docker-compose build backend
```

### Database doesn't exist
```bash
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
```

## Environment Variables

Key environment variables (see `.env.example` for full list):

- `POSTGRES_USER`: PostgreSQL username (default: cliply)
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: Database name (default: cliply_development)
- `DATABASE_HOST`: Database host (localhost for local, postgres for Docker)
- `REDIS_URL`: Redis connection URL
- `FRONTEND_URL`: Frontend URL for CORS configuration
- `JWT_SECRET_KEY`: Secret key for JWT tokens (generate with `rails secret`)

## Next Steps

1. Configure OAuth credentials for Instagram and TikTok in `.env`
2. Set up email configuration for ActionMailer
3. Configure Stripe keys (when ready for payments)
4. Review `backend/CLAUDE.md` for Rails development guidelines
5. Review `frontend/CLAUDE.md` for React development guidelines

## Useful Resources

- [Rails API Documentation](https://api.rubyonrails.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/15/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Sidekiq Documentation](https://github.com/sidekiq/sidekiq/wiki)