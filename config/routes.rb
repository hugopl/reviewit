Rails.application.routes.draw do
  devise_for :users

  root 'projects#index'

  resources :projects do
    resources :merge_requests, only: [:update, :show, :index] do
      get :history, on: :member
      get :ci_status, on: :member
      collection do
        get 'old_ones'
      end
    end
  end

  resources :mr, only: [:show]
  get :faq, controller: :application

  mount Reviewit::API => '/'
end
