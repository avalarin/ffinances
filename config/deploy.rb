lock '3.2.1'

set :application, 'ffinances'

set :repo_url, 'git@github.com:avalarin/ffinances.git'

set :unicorn_config, "#{shared_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/run/unicorn.pid"
set :rails_env, 'production'

set :linked_files, %w{config/unicorn.rb config/database.yml config/settings.yml config/secrets.yml}

set :log_level, :info

desc 'Restart application'
task :restart do
  on roles(:app), in: :sequence, wait: 5 do
    run "#{sudo} service ffinances restart"
  end
end
after :publishing, :restart