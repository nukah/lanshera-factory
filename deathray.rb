require 'stalker'


include Stalker


job 'ls.test' do |args|
    puts args
end
