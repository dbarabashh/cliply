Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      devise_for :users,
                 controllers: {
                   sessions: 'api/v1/users/sessions',
                   registrations: 'api/v1/users/registrations'
                 }

      # Protected routes (require authentication)
      resources :users, only: [:show, :update] do
        member do
          get :me
        end
      end
    end
  end

  # Root route for API
  root to: proc { [200, { 'Content-Type' => 'application/json' }, [{ message: 'Cliply API v1' }.to_json]] }
end
