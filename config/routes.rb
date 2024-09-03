Rails.application.routes.draw do
  root "library#home"

  get "/", to: "library#home"
  get "/collections", to: "collections#show"
  get "/admin", to: "sessions#new"
  post "/admin", to: "sessions#create"
  get "/logout", to: "sessions#delete"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
