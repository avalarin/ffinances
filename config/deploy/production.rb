set :deploy_to, '/var/www/ffinances'

role :app, %w{ffinances.avalarin.net}
role :web, %w{ffinances.avalarin.net}
role :db,  %w{ffinances.avalarin.net}

server 'ffinances.avalarin.net', 
  user: 'ffinances_deploy', 
  roles: %w{web app db},
  ssh_options: {ls
    user: 'ffinances_deploy', port: 2208
  }

namespace :deploy do

  desc 'Link shared configs'
  task :link do
    run "rm -f #{current_release}/config/unicorn.rb"
    run "ln -s #{deploy_to}/shared/config/unicorn.rb #{current_release}/config/unicorn.rb"
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do

    end
  end

  after :publishing, :restart, :link

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do

    end
  end
end