set :deploy_to, '/var/www/ffinances'
set :ssh_options, keys: ["config/deploy_id_rsa"] if File.exist?("config/deploy_id_rsa")

server 'ffinances.avalarin.net',
  user: 'ffinances',
  roles: %w{web app db},
  ssh_options: {
    user: 'ffinances', port: 2208
  }