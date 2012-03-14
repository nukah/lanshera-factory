source 'http://rubygems.org'

gem 'resque', :require => 'resque'
gem 'rake'
gem 'data_mapper'
gem 'ljapi', :git => 'git@github.com:nukah/ljapi.git', :branch => 'master', :require => 'ljapi'

group :development do
    gem 'dm-sqlite-adapter'
    gem 'pry'
end

group 'production' do
    gem 'dm-postgres-adapter'
end
