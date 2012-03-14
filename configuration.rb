$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../'
require 'rubygems'
require 'yaml'
require 'resque'
require 'data_mapper'

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

@config = Configuration.new(YAML.load_file(File.join(Dir.pwd,'config.yml')))
Resque.redis = Redis.new(:host => @config.server, :port => @config.port)

puts Resque.redis
DataMapper.setup(:default, 'sqlite:///Users/Mighty/code/lanshera/db/lanshera.db')