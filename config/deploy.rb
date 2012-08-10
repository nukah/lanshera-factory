set :application, "lanshera-factory"
set :repository,  "https://github.com/nukah/#{application}.git"

default_run_options[:pty] = true

set :scm, :git
set :use_sudo, false
set :user, application
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{application}"
role :app, "remote.host.ip"

set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
set :rvm_type, :user
set :rvm_install_type, :latest
set :branch, "master"
set :default_shell, "/bin/bash"
set :bundle_without, [:development]

before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'

require "rvm/capistrano"
require "bundler/capistrano"
load 'deploy/assets'