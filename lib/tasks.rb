$:.push(File.join(Dir.getwd, 'lib/'))
require "bundler"
Bundler.setup(:default)
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
  
  def perform(operation_id, uname, upass)
    username = uname.to_s
    password = upass.to_s
    operation = operation_id.to_s
    logger.info("#{operation}: Performing access check for account: #{username}.")
    begin
      data = LJAPI::Request::AccessCheck.new(username, password).run
    ensure
      logger.info("#{operation}: Result: #{data[:success]}.")
      data = JSON.generate(data)
      Packager.perform_async(operation, data)
    end
  end
end

class LJImport
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue

  def perform(operation_id, uname, upass)
    username = uname.to_s
    password = upass.to_s
    operation = operation_id.to_s
    logger.info("#{operation}: Performing import of blog #{username}.")
    begin
      access = LJAPI::Request::AccessCheck.new(username, password).run
      if access[:success]
        data = LJAPI::Request::ImportPosts.new(username, password).run 
      else
        data = access
      end
    ensure
      logger.info("#{operation}: Result: #{data[:success]}.")
      logger.info("Cause: #{data}") unless data[:success]
      data = JSON.generate(data)
      Packager.perform_async(operation, data)
    end
  end
end

class LJUpdate
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue
  
  def perform(operation_id, uname, upass, options)
    username = uname.to_s
    password = upass.to_s
    operation = operation_id.to_s
    options['since'] ||= Time.now - 86400
    logger.info("#{operation}: Performing update of blog #{username}.")
    begin
      access = LJAPI::Request::AccessCheck.new(username, password).run
      if access[:success]
        data = LJAPI::Request::GetPosts.new(username,password,options).run
      else
        data = access
      end
    ensure
      logger.info("#{operation}: Result: #{data[:success]}.")
      logger.info("Cause: #{data}") unless data[:success]
      data = JSON.generate(data)
      Packager.perform_async(operation, data)
    end
  end
end

class LJPost
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue

  def perform(operation_id, uname, upass, journal_id, post_id, options = nil)
    username = uname.to_s
    password = upass.to_s
    operation = operation_id.to_s
    journal = journal_id.to_s
    post = post_id.to_s
    logger.info("#{operation}: Performing single post update of post #{post} from blog #{username}.")
    begin
      access = LJAPI::Request::AccessCheck.new(username, password).run
      if access[:success]
        data = LJAPI::Request::GetPost.new(username, password, journal, post, options).run
      else
        data = access
      end
    ensure
      logger.info("#{operation}: Result: #{data[:success]}.")
      logger.info("Cause: #{data}") unless data[:success]
      data = JSON.generate(data)
      Packager.perform_async(operation, data)
    end
  end
end

class LJComment
  include Sidekiq::Worker
  sidekiq_options :queue => @@config.subscribe_queue
  
  def perform(operation_id, uname, upass, journal, post_id, post_subject, post_text)
    username = uname.to_s
    password = upass.to_s
    operation = operation_id.to_s
    journal = journal.to_s
    post = post_id.to_s
    subject = post_subject.to_s
    text = post_text.to_s
    logger.info("#{operation}: Performing commenting of post #{post} from blog #{username}.")
    begin
      access = LJAPI::Request::AccessCheck.new(username, password).run
      if access[:success]
        data = LJAPI::Request::AddComment.new(username, password, journal, post, subject, text).run
      else
        data = access
      end
    ensure
      logger.info("#{operation}: Result: #{data[:success]}.")
      logger.info("Cause: #{data}") unless data[:success]
      data = JSON.generate(data)
      Packager.perform_async(operation, data)
    end
  end

end
