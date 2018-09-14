require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  mount Sidekiq::Web => '/sidekiq'

  get '/housing_units_list', to: 'housing_units_list#index'
  get '/unauthorized', to: 'login#unauthorized', as: :unauthorized_login
  get '/monitors/lb', to: 'monitors#service_online'
end
