# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root 'statistics#index'

  resources :keywords
  resources :posts, only: [:index]
  resources :statistics, only: [:index]

  resources :analyze, only: [:create]

  namespace :api do
    namespace :v1 do
      post 'analyze', to: 'analyze#create'
      get 'analyze/:username', to: 'analyze#show'
      get 'progress/:job_id', to: 'progress#show'
    end
  end

  get 'healthcheck', to: 'application#healthcheck'
end
