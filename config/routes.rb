Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'public#index'

  get '/login', to: 'account#login', as: :login
  post '/login', to: 'account#do_login', as: :login_post
  get '/logout', to: 'account#do_logout', as: :logout
  get '/register', to: 'account#register', as: :register
  post '/register', to: 'account#do_register', as: :register_post
  get '/register/success', to: 'account#success_registration', as: :success_registration
  get '/confirm/:code', to: 'account#confirm', as: :confirm_account

  get '/restore/:code', to: 'restore#change_password', as: :restore_password_confirm
  post '/restore/:code', to: 'restore#update_password', as: :update_password

  get '/restore', to: 'restore#start', as: :restore_password
  post '/restore', to: 'restore#send_email'

  get '/dashboard', to: 'dashboard#index', as: :dashboard

  get '/transaction', to: 'transaction#index', as: :transactions
  get '/transaction/last', to: 'transaction#last', as: :last_transactions
  get '/transaction/new/(:mode)', to: 'transaction#new', as: :new_transaction
  post '/transaction/new', to: 'transaction#create', as: :create_transaction
  get '/transaction/:id', to: 'transaction#details', as: :transaction_details
  delete '/transaction/:id', to: 'transaction#delete', as: :delete_transaction
  get '/transaction/:id/edit', to: 'transaction#edit', as: :edit_transaction
  post '/transaction/update', to: 'transaction#update', as: :update_transaction

  get '/wallet', to: 'wallet#index', as: :wallets_index
  get '/wallet/new', to: 'wallet#new', as: :new_wallet
  post '/wallet/new', to: 'wallet#create', as: :create_wallet

  get '/product', to: 'product#index', as: :products_index

  get '/tag', to: 'tag#index', as: :tags_index
  post '/tag/new', to: 'tag#create', as: :create_tag

  get '/user/:name', to: 'user#profile', as: :user_profile

  namespace :data do
    get '/country', to: 'country#index', as: :countries_index
    get '/country/:code/currencies', to: 'country#currencies', as: :country_currencies_index

    get '/currency', to: 'currency#index', as: :currencies_index
    get '/currency/rate', to: 'currency#rate', as: :currencies_rate

    get '/unit', to: 'unit#index', as: :units_index

    get '/user', to: 'user#index', as: :users_index
  end

  namespace :book, module: 'books' do
    get '/no_books', to: 'main#no_books', as: :no_books
    post '/choose', to: 'main#choose', as: :choose
    get '/index', to: 'main#index', as: :index

    get '/', to: 'main#details', as: :details
    post '/', to: 'main#update', as: :update

    get '/new', to: 'main#new', as: :new
    post '/new', to: 'main#create', as: :create

    get '/users', to: 'user#index', as: :users
    post '/users', to: 'user#create', as: :create_user
    post '/users/:user', to: 'user#update', as: :update_user
  end

  namespace :settings, module: 'settings_area' do
    get '/', to: 'main#index', as: :main

    get '/profile', to: 'profile#index', as: :profile
    post '/profile', to: 'profile#update', as: :update_profile
    post '/profile/avatar', to: 'profile#update_avatar', as: :update_avatar
    post '/profile/send_confirmation_email', to: 'profile#send_confirmation_email', as: :send_confirmation_email

    get '/security', to: 'security#index', as: :security
    post '/security', to: 'security#update', as: :update_security
  end

  namespace :admin do
    get '/', to: 'main#index', as: :main

    get '/user', to: 'user#index', as: :users_index
    post '/user', to: 'user#create', as: :create_user
    post '/user/:user_name/send_email', to: 'user#send_confirmation_email', as: :send_user_confirmation_email
    patch '/user/:user_name', to: 'user#update', as: :update_user

    get '/invite', to: 'invite#index', as: :invites_index
    post '/invite', to: 'invite#create', as: :create_invite
    delete '/invite/:code', to: 'invite#delete', as: :delete_invite
  end

end
