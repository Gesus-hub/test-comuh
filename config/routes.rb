Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "communities#index"

  resources :communities, only: [ :index, :show ]
  resources :messages, only: [ :show ]

  namespace :api do
    namespace :v1 do
      resources :communities, only: [ :create ]
      post "message", to: "messages#create"
      post "messages", to: "messages#create"
      post "reactions", to: "reactions#create"

      get "communities/:id/messages/top", to: "community_messages#top"
      get "analytics/suspicious_ips", to: "analytics#suspicious_ips"
    end
  end
end
