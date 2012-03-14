require 'bundler'
Bundler.require(:default)

require 'resque/tasks'
require 'resque'
require 'ljapi'



class Packager
  @queue = :package
  
  def self.perform(operation_id, data)
    # package data and send it to job-redis
  end
end

class Miner
  @queue = :mine
  
  def self.perform(operation_id, username, password)
    data = LJAPI::Request::GetPosts.new(username,password).run
    data = JSON.generate(data)
    Resque.enqueue(Packager, operation_id, data)
  end
end
