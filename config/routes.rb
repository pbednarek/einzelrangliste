Einzelrangliste::Application.routes.draw do
  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
  resources :challenges, except: [:new]

  get 'challenges/new/:user_id', to: 'challenges#new', as: 'challenge_user'
  post 'challenges/:id/accept', to: 'challenges#accept', as: 'challenge_accept'
end
