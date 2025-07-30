Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Single devise_for :users block for both API and OmniAuth
  namespace :api do
    # Directly use your controller for Google OAuth callback
    post 'users/sign_in', to: 'users/sessions#create'    # Sign in
    delete 'users/sign_out', to: 'users/sessions#destroy' # Sign out (optional)
    post 'users/auth/google_oauth2/callback', to: 'users/google_oauth_callbacks#google_oauth2'
    get 'users/profile', to: 'users#profile'
  end

  # No need for `resources :users` here if Devise is handling the routes
  # resources :users, only: [:show, :update] # Remove this line if not needed

  # Additional resources for proposals
  resources :proposals, only: [:index, :create, :show, :destroy], param: :code
end
