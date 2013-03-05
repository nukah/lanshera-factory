require 'yaml'
require 'sidekiq'
require 'ljapi'

class Configuration
  def initialize(data={})
    @data = {}
    update!(data)
  end

  def update!(data)
    data.each do |key, value|
      self[key] = value
    end
  end

  def [](key)
    @data[key.to_sym]
  end

  def []=(key, value)
    if value.class == Hash
      @data[key.to_sym] = Configuration.new(value)
    else
      @data[key.to_sym] = value
    end
  end

  def method_missing(sym, *args)
    if sym.to_s =~ /(.+)=$/
      self[$1] = args.first
    else
      self[sym]
    end
  end
end

@@config = Configuration.new(YAML.load_file(File.join(Dir.pwd,'config.yml')))
redis_url = "redis://#{@@config.redis_server}:#{@@config.redis_port}"
Sidekiq.configure_server do |config|
  config.redis = { :url => redis_url, :namespace => 'resque' }
end
Sidekiq.configure_client do |config|
  config.redis = { :url => redis_url, :namespace => 'resque' }
end