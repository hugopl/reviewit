Rails.application.routes.draw do
  devise_for :users

  root 'projects#index'

  resources :projects do
    resources :merge_requests, only: [:update, :show, :index] do
      get :history, on: :member
      collection do
       get 'old_ones'
      end
    end
  end

  resources :mr, only: [:show]

  mount Reviewit::API => '/'
end
