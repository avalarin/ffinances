set :deploy_to, '/var/www/ffinances'

server 'ffinances.avalarin.net',
  user: 'ffinances',
  roles: %w{web app db},
  ssh_options: {
    user: 'ffinances', port: 2208
  }

namespace :deploy do
  desc 'Restart ffinances unicorn service'
  task :restart_ffinances do
    on roles(:app) do
      execute "sudo /etc/init.d/ffinances restart"
    end
  end

  after :finished, :restart_ffinances
end