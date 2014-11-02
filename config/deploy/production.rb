set :deploy_to, '/var/www/ffinances'

server 'ffinances.avalarin.net',
  user: 'ffinances',
  roles: %w{web app db},
  ssh_options: {
    user: 'ffinances', port: 2208
  }