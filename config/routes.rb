Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  get '/devices', to: 'devices#index'
  get '/devices/turn_on', to: 'devices#turn_on'
  get '/devices/turn_off', to: 'devices#turn_off'
end
