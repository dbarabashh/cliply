# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Important: Directory-Specific Guidelines

⚠️ **When working in specific directories, follow their local CLAUDE.md rules:**
- **Backend (`/backend`)**: Follow `/backend/CLAUDE.md` for Rails API development
- **Frontend (`/frontend`)**: Follow `/frontend/CLAUDE.md` for React TypeScript development

Each subdirectory has its own architectural patterns, coding standards, and best practices that must be followed.

## MVP Requirements Document

📋 **IMPORTANT: The `/MVP.md` file contains the official MVP requirements and progress tracking.**

- **This file is READ-ONLY for AI** - The MVP.md file can ONLY be modified manually by software engineers
- **Source of Truth** - Contains the authoritative list of MVP features and their completion status
- **Track Progress** - When features are marked as DONE in MVP.md, they are complete and should be preserved
- **Maintain Context** - Always reference MVP.md to understand what has been implemented vs. what remains to be built

## Project Overview

**Cliply** is an MVP SaaS platform that enables creators to schedule and auto-post videos to Instagram and TikTok from a single web dashboard.

### Product Vision
Build a Rails API backend with a React frontend that allows content creators to:
- Schedule videos across multiple social platforms
- Manage posts from a unified dashboard
- Receive notifications about post status
- Link social media accounts securely

### Core Features (MVP)

1. **Authentication**
   - Email/password authentication using Devise with JWT support
   - Secure token management

2. **Account Linking**
   - OAuth integrations for Instagram (via Facebook Graph API)
   - OAuth integrations for TikTok (via TikTok Direct Post API)

3. **Video Scheduling**
   - Upload videos with drag & drop
   - Add captions and metadata
   - Select target platforms
   - Set publication date & time
   - View scheduled posts with status tracking

4. **Backend Processing**
   - Sidekiq for background job processing
   - Redis for job queue management
   - Postgres for data persistence
   - Automated posting at scheduled times

5. **Notifications**
   - Email notifications for post failures via ActionMailer
   - Status updates for scheduled posts

6. **Security**
   - Rails 7 encrypted attributes for OAuth tokens
   - Strong params throughout API
   - JWT-based authentication

## Tech Stack

### Backend
- **Framework:** Ruby on Rails 7 (API-only mode)
- **Database:** PostgreSQL 15+
- **Background Jobs:** Sidekiq with Redis
- **Authentication:** Devise + devise-jwt
- **OAuth:** OmniAuth, Koala (Instagram), custom TikTok integration
- **Email:** ActionMailer
- **Payments:** Stripe (stub for MVP)

### Frontend
- **Framework:** React 19.1.1
- **Language:** TypeScript 5.8.3
- **Build Tool:** Vite 7.1.0
- **Styling:** Tailwind CSS
- **Package Manager:** pnpm
- **Linting:** ESLint 9.32.0

### Infrastructure
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **AI Assistant:** Claude (Anthropic)

## Project Structure

```
cliply/
├── CLAUDE.md              # This file - project overview
├── backend/               # Rails API application
│   ├── CLAUDE.md         # Backend-specific guidelines
│   ├── app/              # Rails application code
│   ├── config/           # Rails configuration
│   ├── db/               # Database migrations and schema
│   ├── spec/             # RSpec tests
│   └── Gemfile           # Ruby dependencies
├── frontend/              # React TypeScript application
│   ├── CLAUDE.md         # Frontend-specific guidelines
│   ├── src/              # React source code
│   ├── public/           # Static assets
│   ├── package.json      # Node dependencies
│   └── vite.config.ts    # Vite configuration
└── docker/               # Docker configuration files
```

## Development Workflow

### Backend Development

#### With Docker (Recommended)
```bash
# Start all services
docker-compose up -d

# Set up database
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:test:prepare

# Access Rails console
docker-compose exec backend rails console

# Run tests
docker-compose exec backend rspec
```

#### Without Docker
```bash
cd backend
bundle install        # Install Ruby gems
rails db:create      # Create development and test databases
rails db:migrate     # Run migrations (includes PostgreSQL extensions)
rails server         # Start API server (port 3000)
rspec               # Run tests
```

### Frontend Development
```bash
cd frontend
pnpm install        # Install Node packages
pnpm dev           # Start dev server (port 5173)
pnpm build         # Build for production
pnpm lint          # Run linting
```

### Full Stack Development
```bash
# Using Docker Compose (from root)
docker-compose up   # Start all services (PostgreSQL, Redis, Rails, Sidekiq)

# Services available at:
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379  
# - Rails API: http://localhost:3000
# - Frontend: http://localhost:5173 (run separately with pnpm dev)
```

## API Communication

- Backend runs on `http://localhost:3000`
- Frontend runs on `http://localhost:5173`
- API endpoints follow RESTful conventions under `/api/v1/`
- CORS configured for cross-origin requests
- JWT tokens used for authentication

## Success Metrics

The MVP is considered successful when:
- At least 20 unique users connect an account and schedule 3+ posts within the first month
- <5% failure rate for scheduled posts
- Scheduled posts go live within 2 minutes of target time
- >99% uptime for the Sidekiq scheduler

## Non-Functional Requirements

- Mobile-friendly, responsive web UI (web-first approach)
- Comprehensive Rails logging for debugging
- Error tracking and monitoring (Sentry planned post-MVP)
- Performance optimization for video uploads
- Secure storage of OAuth tokens

## Development Principles

### General Guidelines
1. **Follow directory-specific CLAUDE.md files** when working in backend or frontend
2. **Convention over configuration** - Use framework defaults
3. **Keep it simple** - Avoid premature optimization
4. **Test critical paths** - Focus testing on core functionality
5. **Document API changes** - Keep API documentation current

### Code Quality
- Write clean, readable code
- Follow established patterns in the codebase
- Add tests for new features
- Review security implications of changes
- Keep dependencies up to date

### Git Workflow
- Feature branches for new work
- Descriptive commit messages
- PR reviews before merging
- Keep main branch deployable

## Quick Start

1. Clone the repository
2. Copy environment variables: `cp .env.example .env`
3. Start Docker services: `docker-compose up -d`
4. Set up database:
   ```bash
   docker-compose exec backend rails db:create
   docker-compose exec backend rails db:migrate
   ```
5. Start frontend: `cd frontend && pnpm install && pnpm dev`
6. Access app at `http://localhost:5173`

For detailed setup instructions, see `/SETUP.md`

## Important Notes

- **Always check directory-specific CLAUDE.md files** for detailed guidelines
- Backend follows Rails/DHH philosophy for API development
- Frontend follows React best practices with hooks and context
- Use Docker for consistent development environment
- Maintain separation between frontend and backend concerns