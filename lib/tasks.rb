require "bundler"
require 'configuration'
require 'json/ext'
require 'ljapi'

Bundler.setup(:default)

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
    logger.info("Performing task on LJAPI version: #{LJAPI::Utils.version}")
    begin
      @data = LJAPI::Request::AccessCheck.new(@username, @password).run
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
    logger.info("Performing task on LJAPI version: #{LJAPI::Utils.version}")
    begin
      @data = LJAPI::Request::ImportPosts.new(@username, @password).run
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
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
    @options['since'] ||= Time.now - 86400
    begin
      @data = LJAPI::Request::GetPosts.new(@username,@password,@options).run
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
    ensure
      @data = JSON.generate(@data)
      Packager.perform_async(@operation, @data)
    end
  end

end
