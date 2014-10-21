Rails.application.routes.draw do
  devise_for :users

  root 'projects#index'

  resources :projects do
    resources :merge_requests, only: [:update, :show, :index] do
      collection do
       get 'old_ones'
      end
    end
  end

  resources :mr, only: [:show]

  namespace :api do
    resources :projects, only: [] do
      get 'setup', on: :member
      resources :merge_requests, only: [:create, :update, :index, :show, :destroy] do
        get 'show_git_patch', on: :member
      end
    end
  end
end
