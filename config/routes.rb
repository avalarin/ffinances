Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#index'

  get '/login', to: 'account#login', as: :login
  post '/login', to: 'account#do_login', as: :login_post
  get '/logout', to: 'account#do_logout', as: :logout
  get '/register', to: 'account#register', as: :register
  post '/register', to: 'account#do_register', as: :register_post
  get '/register/success', to: 'account#success_registration', as: :success_registration
  get '/confirm/:code', to: 'account#confirm', as: :confirm_account

  get '/dashboard', to: 'dashboard#index', as: :dashboard

  get '/transaction', to: 'transaction#index', as: :transactions_index
  get '/transaction/new/(:mode)', to: 'transaction#new', as: :new_transaction
  post '/transaction/new', to: 'transaction#create', as: :create_transaction

  get '/wallet', to: 'wallet#index', as: :wallets_index
  get '/wallet/new', to: 'wallet#new', as: :new_wallet
  post '/wallet/new', to: 'wallet#create', as: :create_wallet

  get '/product', to: 'product#index', as: :products_index

  get '/tag', to: 'tag#index', as: :tags_index
  post '/tag/new', to: 'tag#create', as: :create_tag

  get '/book', to: 'book#index', as: :books_index
  get '/book/current', to: 'book#current', as: :current_book
  post '/book/choose', to: 'book#choose', as: :choose_book
  get '/book/new', to: 'book#new', as: :new_book
  post '/book/new', to: 'book#create', as: :create_book
  get '/book/:key', to: 'book#details', as: :book_details

  post '/book/:key', to: 'book#update', as: :update_book
  get '/book/:key/users', to: 'book#users', as: :book_users
  post '/book/:key/users', to: 'book#add_user', as: :add_book_user
  post '/book/:key/users/:user', to: 'book#update_user', as: :update_book_user

  namespace :data do
    get '/country', to: 'country#index', as: :countries_index
    get '/country/:code/currencies', to: 'country#currencies', as: :country_currencies_index

    get '/currency', to: 'currency#index', as: :currencies_index
    get '/currency/rate', to: 'currency#rate', as: :currencies_rate

    get '/unit', to: 'unit#index', as: :units_index

    get '/user', to: 'user#index', as: :users_index
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
