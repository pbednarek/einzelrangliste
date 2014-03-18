Einzelrangliste::Application.routes.draw do
  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
  resources :challenges, except: [:new]

  get 'challenges/new/:user_id', to: 'challenges#new', as: 'challenge_user'
  post 'challenges/:id/accept', to: 'challenges#accept', as: 'challenge_accept'
  post 'challenges/:id/deny', to: 'challenges#deny', as: 'challenge_deny'

  get 'admin', to: 'admin#index', as: 'admin'
  post 'admin/accept_reason', to:'admin#accept_reason', as: 'accept_reason'
  post 'admin/deny_reason', to:'admin#deny_reason', as: 'deny_reason'
end
