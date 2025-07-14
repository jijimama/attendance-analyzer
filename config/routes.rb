Rails.application.routes.draw do
  root "attendances#new"
  resources :attendances, only: [:new, :create]
end
