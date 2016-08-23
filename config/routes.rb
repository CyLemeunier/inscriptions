Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  get '/credit_insuffisant' => 'pages#credit_insuffisant'
  get '/comment_ca_fonctionne' => 'pages#comment_ca_fonctionne'
  resources :players do
    resources :transactions
  end
  resources :tournaments do
    resources :registrations
  end

end
