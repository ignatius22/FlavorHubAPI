Rails.application.routes.draw do
  # == Admin Interfaces ==
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq", as: :sidekiq_admin

  # == Health Checks ==
  get "up", to: "rails/health#show", as: :rails_health_check

  # == Web Application ==
  root "welcome#index"

  # == API Endpoints ==
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # User Management
      resources :users, only: %i[index show create update destroy] do
        collection do
          get :active_users_with_orders
          get :recently_active_users
          get :current, action: :current
        end

        member do
          get :profile, action: :profile
          patch :update_profile
        end
      end

      # Authentication
      resources :sessions, only: [:create] do
        post :login, on: :collection
      end

      # Password Management
      resources :password_resets, only: %i[create edit update] do
        collection do
          post :request_reset, action: :create
          get :edit
          patch :update
        end
      end

      # Product Management
      resources :products, only: %i[index show create update] do
        get :favorites, on: :collection
        post :toggle_favorite, on: :member
        delete :archive, on: :member          # Added for archive
        patch :unarchive, on: :member
        delete :delete_permanently, on: :member  # Added for permanent delete
      end

      # Order Management
      resources :orders, only: %i[index show create update destroy] do
        collection do
          get :active, action: :active
          get :recent, action: :recent
        end

        member do
          patch :cancel
          patch :ship
        end

        # Nested Order Items
        resources :order_items, only: %i[index show create update destroy], shallow: true
      end
    end
  end

  # == Route Constraints ==
  if Rails.env.production?
    constraints subdomain: "api" do
      namespace :api do
        # Mirror of API routes for subdomain access
      end
    end
  end

  # == Custom Routing Helpers ==
  # Add any custom route helpers here if needed
  # get "/:username", to: "users#show", as: :user_profile
end