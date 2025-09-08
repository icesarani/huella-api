# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      get 'health_check' => 'base#health_check', as: :health_check

      devise_scope :user do
        resource :sessions, only: %i[create destroy]

        resource :registrations, only: %i[create]
      end

      resources :certification_requests, only: [:create] do
        member do
          post :certify
        end
      end

      resource :viewer, only: [:show]

      resources :localities, only: [:index]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
