lock '3.2.1'

set :application, 'ffinances'

set :repo_url, 'git@github.com:avalarin/ffinances.git'

set :unicorn_config, "#{shared_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/run/unicorn.pid"
set :rails_env, 'production'

set :linked_files, %w{config/unicorn.rb config/database.yml config/settings.yml config/secrets.yml}
set :linked_dirs, %w{public/system public/assets log}
set :log_level, :info