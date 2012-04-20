require 'bundler'
Bundler.require(:default)
require 'ljapi'
require 'lanshera'

class Packager
  @queue = @@config.publish_queue
  
  def self.perform(operation_id, data)
    # package data and send it to job-redis
  end
end

class Miner
  @queue = @@config.subscribe_queue
  
  def self.perform(operation_id, username, password)
    begin
      data = LJAPI::Request::GetPosts.new(username,password).run
    rescue Exception => e
      data = { :success => false, :data => e.message }
    ensure
      data = JSON.generate(data)
      Resque.enqueue(Packager, operation_id, data)
    end
  end
  def to_s
    ''
  end
end

class Commenter
  @queue = @@config.subscribe_queue
  
  def self.perform(operation_id, username, password, journal, post_id, subject, text)
    begin
      data = LJAPI::Request::AddComment.new(username, password, journal, post_id, subject, text).run
    rescue Exception => e
      data = { :success => false, :data => e.message }
    ensure
      data = JSON.generate(data)
      Resque.enqueue(Packager, operation_id, data)
    end
  end
  
  def to_s
    'lanshera::add_comment'
  end
end