Rails.application.routes.draw do

  root 'application#index', as: :landing_page

  get 'users', to: 'users#index', as: :users
  get 'leaderboard', to: 'users#leaderboard', as: :leaderboard
  get 'signup', to: 'users#new', as: :new_user
  post 'signup', to: 'users#create', as: :create_user
  get 'dashboard', to: 'users#dashboard', as: :user_dashboard
  get 'settings', to: 'users#show', as: :user
  get 'changepassword', to: 'users#edit_password', as: :edit_password
  patch 'changepassword', to: 'users#update_password', as: :update_password
  get 'deleteaccount', to: 'users#confirm_delete', as: :confirm_delete_user
  delete 'deleteaccount', to: 'users#destroy', as: :delete_user

  get 'login', to: 'sessions#new', as: :new_session
  post 'login', to: 'sessions#create', as: :create_session
  get 'logout' => 'sessions#destroy', as: :destroy_session

  get 'placebets/:sport', to: 'bets#new', as: :new_bets
  post 'placebets/:sport', to: 'bets#create', as: :create_bets
  get 'bets/pending', to: 'bets#show_pending', as: :pending_bets
  get 'bets/history', to: 'bets#show_history', as: :bet_history

end
