set :deploy_to, '/var/www/ffinances'
set :ssh_options, keys: ["config/keys/production_deploy_rsa"] if File.exist?("config/keys/production_deploy_rsa")

server 'ffinances.avalarin.net',
  user: 'ffinances',
  roles: %w{web app db},
  ssh_options: {
    user: 'ffinances', port: 2208
  }