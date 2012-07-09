#!/usr/bin/env rake
$:.push(File.join(Dir.pwd,'/lib'))
require 'resque/tasks'
require 'resque'
require 'configuration'
require 'tasks'


task :start, [:amount] do |task, args|
  ENV['QUEUE'] = @@config.subscribe_queue
  ENV['BACKGROUND'] = 'TRUE' if @@config.worker_daemon
  ENV['PIDFILE'] = @@config.worker_daemon_pid if (@@config.worker_daemon && @@config.worker_daemon_pid)
  Rake::Task['resque:work'].execute()
end

namespace :test do
  task :mine, [:username, :password] do |task, args|
    uid = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    args.with_defaults(:operation_id => uid, :username => 'test', :password => 'test')
    Resque.enqueue(Miner, uid, args.username, args.password)
  end

  task :dig, [:username, :password, :journal, :post] do |task, args|
    uid = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    args.with_defaults(:operation_id => uid, :username => 'test', :password => 'test', :journal => 'test', :post => 1)
    Resque.enqueue(Digger, uid, args.username, args.password, args.journal, args.post)
  end
  
  task :comment, [:username, :password, :journal, :post_id, :subject, :text] do |task, args|
    uid = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    args.with_defaults(:operation_id => uid, :username => 'test', :password => 'test', :journal => 'test',
                       :post_id => '15', :subject => 'test subject', :text => 'commentary')
    Resque.enqueue(Commenter, uid, args.username, args.password, args.journal, args.post_id, args.subject, args.text)
  end
end
