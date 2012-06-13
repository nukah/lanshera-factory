require 'bundler'
Bundler.require(:default)
require 'ljapi'
require 'lanshera'

JSON.generator = JSON::Ext::Generator

class Packager
  @queue = @@config.publish_queue
  
  def self.perform(operation_id, data)
    # package data and send it to job-redis
  end
end

class InitialImport
  @queue = @@config.subscribe_queue

  def self.perform(operation_id, username, password)
    begin
      post_count = LJAPI::Request::GetPost.new(username, password, username, -1).run[:data]['events'][0]['itemid'].to_i
      import_ids = (1..post_count).to_a
      posts = []
      if post_count > 100
        while import_ids.length > 0 do
          posts << LJAPI::Request::GetPosts.new(username, password, { 'itemids' => import_ids.slice!(0,100).join(',') }).run[:data]['events']
        end
        data = { :success => true, :data => { 'events' => posts.flatten }}
      else
        data = LJAPI::Request::GetPosts.new(username,password,options).run
      end
    rescue Exception => e
      data = { :success => false, :data => e.message }
    ensure
      data = JSON.generate(data)
      Resque.enqueue(Packager, operation_id, data)
    end
  end
end

class Miner
  @queue = @@config.subscribe_queue
  
  def self.perform(operation_id, username, password, options = nil)
    begin
      if options && options.has_key?('since')
        data = LJAPI::Request::GetPosts.new(username,password,options).run
      else
        data = LJAPI::Request::GetPosts.new(username,password).run
      end
    rescue Exception => e
      data = { :success => false, :data => e.message }
    ensure
      data = JSON.generate(data)
      Resque.enqueue(Packager, operation_id, data)
    end
  end
end

class Digger
  @queue = @@config.subscribe_queue

  def self.perform(operation_id, username, password, journal_id, post_id, options = nil)
    begin
        data = LJAPI::Request::GetPost.new(username, password, journal_id, post_id, options).run
    rescue Exception => e
        data = { :success => false, :data => e.message }
    ensure
        data = JSON.generate(data)
        Resque.enqueue(Packager, operation_id, data)
    end
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

end
