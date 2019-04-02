Rails.application.routes.draw do
  get 'home/index'
  devise_for :users

  root 'home#index'
  get 'home' => 'home#index'
  get 'sign-in' => 'home#sign_in'
  get 'sign-up' => 'home#sign_up'
  get 'film-list' => 'home#film_list'
end
