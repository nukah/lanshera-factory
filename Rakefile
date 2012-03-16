#!/usr/bin/env rake
require 'bundler'
Bundler.require(:default)

require './configuration'
require 'resque/tasks'
require 'resque'
require 'ljapi'

task :start do
  ENV['QUEUE'] = @@config.subscribe_queue
  ENV['VERBOSE'] = '1' if @@config.worker_verbose
  ENV['BACKGROUND'] = '1' if @@config.worker_daemon
  ENV['PIDFILE'] = @@config.worker_daemon_pid if (@@config.worker_daemon && @@config.worker_daemon_pid)
  Rake::Task['resque:work'].execute()
end

namespace :test do
  task :mine, [:username, :password] do |task, args|
    uid = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    args.with_defaults(:operation_id => uid, :username => 'test', :password => 'test')
    Resque.enqueue(Miner, uid, args.username, args.password)
  end
end

class Packager
  @queue = @@config.publish_queue
  
  def self.perform(operation_id, data)
    # package data and send it to job-redis
  end
end

class Miner
  @queue = @@config.subscribe_queue
  
  def self.perform(operation_id, username, password)
    data = LJAPI::Request::GetPosts.new(username,password).run
    data = JSON.generate(data)
    Resque.enqueue(Packager, operation_id, data)
  end
end

class Commenter
  @queue = @@config.subscribe_queue
  
  def self.perform(operation_id, username, password, journal, post_id, subject, text)
    data = LJAPI::Request::AddComment.new(username, password, journal, post_id, subject, text).run
    data = JSON.generate(data)
    resque.enqueue(Packager, operation_id, data)
  end
end