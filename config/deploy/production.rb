set :deploy_to, '/var/www/ffinances'

server 'ffinances.avalarin.net',
  user: 'ffinances',
  roles: %w{web app db},
  ssh_options: {
    user: 'ffinances', port: 2208
  }

namespace :deploy do
 task :start do ; end
 task :stop do ; end
 task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{sudo} service ffinances restart"
 end
end