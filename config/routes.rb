require 'sidekiq/web'

Kernel.load Rails.root.join('lib', 'reviewit', 'lib', 'reviewit', 'version.rb') unless defined? Reviewit::VERSION

Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration,
             only: %i(new create edit update),
             path: 'users',
             path_names: { new: 'sign_up' },
             as: :user_registration do
               get :cancel
             end
  end

  post '/configure_webpush' => 'users#configure_webpush'
  root 'projects#index'

  resources :projects do
    resources :merge_requests, only: %i(update show index) do
      member do
        get :history
        get :ci_status
        get :trigger_ci
        post :solve_issues
      end
      collection do
        get 'old_ones'
      end
    end
  end

  resources :mr, only: [:show]
  get :faq, controller: :application
  get '/:id', to: 'errors#show', constraints: { id: /\d{3}/ }

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  mount Reviewit::API => '/'
end
