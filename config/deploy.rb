require 'io/console'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina_sidekiq/tasks'
require 'mina/unicorn'

domain = ENV['DOMAIN']
deploy_to = ENV['DEPLOY_TO'] || '/home/reviewit'
branch = ENV['BRANCH'] || 'master'
user = ENV['DEPLOY_USER'] || 'reviewit'
abort('Set the DOMAIN env. var to hostname where reviewit will be deployed.') if ENV['DOMAIN'].nil?

puts 'Deploying reviewit to:'
puts
puts "domain: #{domain}"
puts "branch: #{branch}"
puts "user:   #{user}"
puts
puts 'If you want to change something, check the file config/deploy.rb.'
puts 'Ok? [Yn]'
abort('Deploy aborted') if STDIN.getch.upcase != 'Y'

# Basic settings:
set :application_name, 'reviewit'
set :domain, domain
set :deploy_to, deploy_to
set :repository, 'https://github.com/hugopl/reviewit.git'
set :branch, branch
set :user, user
set :forward_agent, true
set :sidekiq_pid, 'tmp/pids/sidekiq.pid'
set :sidekiq_log, 'log/sidekiq.log'

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/reviewit.yml', 'config/unicorn.rb')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  invoke :'rvm:use', 'default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'sidekiq:quiet'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'rvm:use', 'default'
      command '~/.rvm/bin/rvm default do bundle exec rake build_cli_gem'
      invoke :'unicorn:restart'
      invoke :'sidekiq:restart'
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
