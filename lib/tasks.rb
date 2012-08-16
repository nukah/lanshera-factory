$:.push(File.join(Dir.getwd, 'lib/'))
require 'bundler/setup'
require 'configuration'
require 'json/ext'
require 'ljapi'

class Packager
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.publish_queue
  
  def perform(operation_id, data)
    # package data and send it to job-redis
  end
end

class LJAccess
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue
  
  def perform(operation_id, username, password)
    @username = username.to_s
    @password = password.to_s
    @operation = operation_id.to_s
    begin
      @data = LJAPI::Request::AccessCheck.new(@username, @password).run
    rescue Exception => e
      @data = { :success => false, :data => e.message }
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
    end
  end
end

class LJImport
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue

  def perform(operation_id, username, password)
    @username = username.to_s
    @password = password.to_s
    @operation = operation_id.to_s
    begin
      count = LJAPI::Request::GetPost.new(@username, @password, @username, -1).run[:data]['events'][0]['itemid'].to_i
      post_ids = (1..count).to_a
      posts = []
      if count > 100
        while post_ids.length > 0 do
          posts.insert(-1, LJAPI::Request::GetPosts.new(@username, @password, { 'itemids' => post_ids.slice!(0,100).join(',') }).run[:data]['events'])
        end
        @data = { :success => true, :data => { 'events' => posts.flatten }}
      else
        @data = LJAPI::Request::GetPosts.new(@username,@password).run
      end
    rescue Exception => e
      @data = { :success => false, :data => e.message }
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
      return @data
    end
  end
end

class LJUpdate
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue
  
  def perform(operation_id, username, password, options)
    @username = username.to_s
    @password = password.to_s
    @options = options
    @operation = operation_id.to_s
    begin
      @data = LJAPI::Request::GetPosts.new(@username,@password,@options).run if @options.has_key?('since')
    rescue Exception => e
      @data = { :success => false, :data => e.message }
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
    end
  end
end

class LJPost
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue

  def perform(operation_id, username, password, journal_id, post_id, options = nil)
    @username = username.to_s
    @password = password.to_s
    @operation = operation_id.to_s
    @journal = journal_id.to_s
    @post_id = post_id.to_s
    begin
      @data = LJAPI::Request::GetPost.new(@username, @password, @journal, @post_id, options).run
    rescue Exception => e
      @data = { :success => false, :data => e.message }
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
    end
  end
end

class LJComment
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue
  
  def perform(operation_id, username, password, journal, post_id, subject, text)
    @username = username.to_s
    @password = password.to_s
    @operation = operation_id.to_s
    @journal = journal.to_s
    @post = post_id.to_s
    @subject = subject.to_s
    @text = text.to_s
    begin
      @data = LJAPI::Request::AddComment.new(@username, @password, @journal, @post, @subject, @text).run
    rescue Exception => e
      @data = { :success => false, :data => e.message }
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
    end
  end

end
