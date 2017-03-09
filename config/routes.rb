Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  get '/credit_insuffisant' => 'pages#credit_insuffisant'
  get '/comment_ca_fonctionne' => 'pages#comment_ca_fonctionne'
  get '/registrations' => 'registrations#all_registrations'

  resources :players do
    resources :transactions
  end
  resources :tournaments do
    post 'update_tournoiclub', to: "tournaments#update_tournoiclub"
    resources :registrations
  end

end
