Kernel.load Rails.root.join('lib', 'reviewit', 'lib', 'reviewit', 'version.rb') unless defined? Reviewit::VERSION

Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration,
      only: [:new, :create, :edit, :update],
      path: 'users',
      path_names: { new: 'sign_up' },
      controller: 'devise/registrations',
      as: :user_registration do
        get :cancel
      end
  end

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
