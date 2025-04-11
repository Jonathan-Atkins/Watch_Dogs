Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users, only: [:create, :index, :show]
      resources :sessions, only: :create
      resources :movies, only: [:index, :show] 
      resources :viewing_parties, only: [:create, :show, :update]
    end
  end
end