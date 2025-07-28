Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
             controllers: {
               sessions: 'api/sessions',
               registrations: 'api/registrations',
               omniauth_callbacks: 'users/omniauth_callbacks'
             },
             defaults: { format: :json }

  resources :users, only: [:index, :show]
  resources :proposals, only: [:index, :create, :show, :destroy], param: :code

  # Defines the root path route ("/")
  # root "posts#index"
end
