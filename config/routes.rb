# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :keywords
  resources :posts, only: [:index] do
    resources :comments, only: [:index]
  end
  root 'statistics#index'

  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :analyze, only: [:create]
      get 'analyze/:username', to: 'analyze#show'
      get 'progress/:job_id', to: 'progress#show'
    end
  end
end
