# CLAUDE.md

This file provides guidance to Claude Code when working with the Rails API backend codebase.

## Project Overview

This is a Rails API-only application that serves as the backend for the Cliply frontend React application.

## Project Philosophy

Following David Heinemeier Hansson's (DHH) Rails philosophy adapted for API development:
- **Convention over Configuration** - Embrace Rails conventions, don't fight the framework
- **Majestic Monolith** - Keep it simple, avoid premature service extraction
- **No Premature Optimization** - Write clear code first, optimize when proven necessary
- **Conceptual Compression** - Reduce concepts, not just lines of code
- **API-First Design** - Clean, consistent JSON APIs

## Ruby/Rails Code Style

### General Principles
- **Clarity over cleverness** - Code should read like well-written prose
- **Fat models, skinny controllers** - Business logic belongs in models
- **Two spaces for indentation** - Never tabs
- **No trailing whitespace**
- **UTF-8 encoding**

### Ruby Style
```ruby
# Good - Clear intent
def publish!
  update!(published: true, published_at: Time.current)
end

# Bad - Too clever
def publish!
  tap { |p| p.update!(published: true, published_at: Time.current) }
end
```

### Rails API Patterns

#### API Controllers
- Inherit from `ActionController::API` not `ApplicationController::Base`
- Return JSON responses consistently
- Use proper HTTP status codes
- Handle errors gracefully with consistent error format
- RESTful actions only (index, show, create, update, destroy) - no new/edit for APIs

```ruby
class Api::V1::ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :update, :destroy]

  def index
    @articles = Article.all
    render json: @articles
  end

  def show
    render json: @article
  end

  def create
    @article = Article.new(article_params)
    
    if @article.save
      render json: @article, status: :created
    else
      render json: { errors: @article.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: { errors: @article.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    head :no_content
  end

  private
    def set_article
      @article = Article.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Article not found' }, status: :not_found
    end

    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

#### API Versioning
- Use URL versioning (e.g., `/api/v1/`)
- Keep versions in separate controller namespaces

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :articles
      resources :users
    end
  end
end
```

#### Serialization
- Use Active Model Serializers or Jbuilder for complex JSON structures
- Keep serialization logic out of controllers
- Be consistent with JSON key format (prefer snake_case)

```ruby
# Using Active Model Serializers
class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :published, :published_at, :created_at, :updated_at
  
  belongs_to :author
  has_many :comments
end

# Or using Jbuilder
# app/views/api/v1/articles/show.json.jbuilder
json.article do
  json.extract! @article, :id, :title, :body, :published, :created_at, :updated_at
  json.author do
    json.extract! @article.author, :id, :name, :email
  end
end
```

#### Error Handling
- Consistent error response format
- Use concern for shared error handling

```ruby
# app/controllers/concerns/error_handler.rb
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { errors: e.record.errors }, status: :unprocessable_entity
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include ErrorHandler
end
```

#### Authentication & Authorization
- Use JWT tokens for stateless authentication
- Include authentication in ApplicationController
- Use before_action for authorization

```ruby
class ApplicationController < ActionController::API
  before_action :authenticate_request

  private
    def authenticate_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      
      decoded = JsonWebToken.decode(header)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
end
```

#### CORS Configuration
- Configure CORS properly for frontend access

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('FRONTEND_URL', 'http://localhost:5173')
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

#### Models
- Use Active Record callbacks judiciously
- Prefer scopes over class methods for queries
- Validate at the model level
- Keep business logic in models or service objects

```ruby
class Article < ApplicationRecord
  belongs_to :author
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  def publish!
    update!(published: true, published_at: Time.current)
  end
end
```

#### Pagination
- Use Kaminari for pagination
- Include pagination metadata in responses

```ruby
def index
  @articles = Article.page(params[:page]).per(params[:per_page] || 25)
  
  render json: {
    articles: @articles,
    meta: {
      current_page: @articles.current_page,
      total_pages: @articles.total_pages,
      total_count: @articles.total_count
    }
  }
end
```

#### Database (PostgreSQL)
- Use migrations for schema changes
- Indexes on foreign keys and frequently queried columns
- Use database constraints when appropriate
- Prefer `change` method in migrations when reversible
- Leverage PostgreSQL-specific features when beneficial

```ruby
class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.boolean :published, default: false, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :articles, :published
    add_index :articles, :published_at
  end
end
```

##### PostgreSQL Extensions
The project uses these PostgreSQL extensions (enabled via migration):
- **uuid-ossp**: For UUID generation (use for public-facing IDs)
- **pg_trgm**: For fuzzy text searching
- **pgcrypto**: For secure token generation

```ruby
# Example: Using UUID for primary key
create_table :api_tokens, id: :uuid do |t|
  t.references :user, null: false, foreign_key: true
  t.string :token_digest, null: false
  t.timestamps
end

# Example: Using trigram search
Article.where("title % ?", "search term")  # Fuzzy search
```

### Testing Philosophy for APIs
- Test API endpoints with request specs
- Test JSON response structure and content
- Test different HTTP status codes
- Use fixtures or factories consistently

```ruby
# spec/requests/api/v1/articles_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do
    it "returns all articles" do
      create_list(:article, 3)
      
      get "/api/v1/articles"
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "POST /api/v1/articles" do
    context "with valid parameters" do
      it "creates a new article" do
        valid_attributes = { article: { title: "Test", body: "Test content" } }
        
        post "/api/v1/articles", params: valid_attributes
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["title"]).to eq("Test")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        invalid_attributes = { article: { title: "" } }
        
        post "/api/v1/articles", params: invalid_attributes
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
```

### Anti-patterns to Avoid
- **Callback hell** - Too many Active Record callbacks
- **God objects** - Models doing too much
- **Anemic models** - All logic in controllers or services
- **N+1 queries** - Use `includes` for associations
- **Raw SQL** - Use Active Record query interface

### Performance Considerations
- Use `includes` to avoid N+1 queries
- Add database indexes for foreign keys and filtered columns
- Use counter caches for association counts
- Prefer `find_each` for large datasets
- Cache expensive computations

```ruby
# Good - Avoids N+1
Article.includes(:author, :comments).recent

# Good - Uses counter cache
class Article < ApplicationRecord
  has_many :comments, counter_cache: true
end
```

### Security Best Practices
- Always use strong parameters
- Never trust user input
- Use Rails' built-in CSRF protection
- Sanitize HTML content
- Use `params.require` and `params.permit`

### Code Organization for API
```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── api/
│   │   └── v1/           # Versioned API controllers
│   │       ├── base_controller.rb
│   │       └── articles_controller.rb
│   └── concerns/         # Shared controller modules
├── models/
│   ├── application_record.rb
│   └── concerns/         # Shared model modules
├── serializers/          # JSON serializers
├── services/             # Business logic services
├── mailers/              # Email functionality
└── jobs/                 # Background jobs

config/
├── routes.rb             # API namespace routing
└── initializers/
    └── cors.rb          # CORS configuration
```

### Development Workflow
1. Write tests first (when it makes sense)
2. Implement the simplest solution
3. Refactor when patterns emerge
4. Extract abstractions only when needed

### DHH's Key Principles Applied
- **YAGNI (You Aren't Gonna Need It)** - Don't build for hypothetical futures
- **DRY (Don't Repeat Yourself)** - But don't abstract prematurely
- **Progress over Perfection** - Ship working code, iterate
- **Embrace the Monolith** - Start simple, extract services only when necessary
- **No Cargo Culting** - Understand why, don't just copy patterns

## Environment Setup

```bash
# Copy environment variables
cp ../.env.example ../.env

# Key environment variables for Rails:
# DATABASE_URL: PostgreSQL connection string
# REDIS_URL: Redis connection for Sidekiq
# JWT_SECRET_KEY: For JWT authentication
# FRONTEND_URL: For CORS configuration
```

## Common Commands

```bash
# Development server (API on port 3000)
rails server

# Rails console
rails console

# Run tests (RSpec)
rspec
rspec spec/requests/api/v1/articles_spec.rb

# Run tests (Minitest)
rails test
rails test test/models/article_test.rb

# Database operations (PostgreSQL)
rails db:create      # Creates development and test databases
rails db:migrate     # Run migrations
rails db:seed        # Load seed data
rails db:reset       # Drop, create, migrate, seed
rails db:test:prepare # Prepare test database

# With Docker
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
docker-compose exec backend rails console

# Access PostgreSQL directly
docker-compose exec postgres psql -U cliply -d cliply_development

# Generate API resources
rails generate model Article title:string body:text
rails generate controller api/v1/articles --api
rails generate serializer Article

# Routes
rails routes
rails routes -g api  # grep for API routes

# Check API with curl
curl -X GET http://localhost:3000/api/v1/articles
curl -X POST http://localhost:3000/api/v1/articles \
  -H "Content-Type: application/json" \
  -d '{"article":{"title":"Test","body":"Content"}}'
```

## API Documentation
- Use tools like Swagger/OpenAPI for API documentation
- Document endpoints, parameters, and responses
- Keep documentation up-to-date with code

```ruby
# Using rswag for OpenAPI documentation
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.swagger_root = Rails.root.to_s + '/swagger'
  
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Cliply API V1',
        version: 'v1'
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ]
    }
  }
end
```

## Ruby Version
- Use `.ruby-version` file for version management
- Prefer latest stable Ruby version

## Rate Limiting & Throttling
- Implement rate limiting for API endpoints
- Use Rack::Attack or similar middleware

```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle('api', limit: 100, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api')
end
```

## Background Jobs
- Use Sidekiq or Active Job for async processing
- Keep API responses fast by offloading heavy work

```ruby
class ArticleIndexJob < ApplicationJob
  queue_as :default

  def perform(article)
    # Heavy processing like search indexing
    SearchIndexer.index(article)
  end
end
```

## Remember
"Programmer happiness" is a core Rails value. Write code that makes you and your team happy to work with it. When in doubt, choose the solution that's easier to understand and maintain.

For API development specifically:
- Keep endpoints RESTful and predictable
- Return consistent JSON structures
- Use proper HTTP status codes
- Version your API from the start
- Document everything