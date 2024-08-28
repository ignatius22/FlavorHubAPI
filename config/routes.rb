Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "welcome#index"
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy] do
        collection do
          get :active_users_with_orders
        end
        member do
          get :show_profile, to: 'users#show_profile'
          patch :update_profile, to: 'users#update_profile'
        end
      end
      resources :sessions, only: [:create]
      resources :password_resets, only: [:create, :edit, :update]
      resources :products, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get :favorites
        end
        member do
          post :toggle_favorite
        end
      end
    end
  end  
end
