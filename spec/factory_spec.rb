require 'configuration'
require 'tasks'
require 'rake'

describe "Harvester testing" do
  before do
    user = double('user', :username => 'fir3', :password => 'f1rewall')
    Rake::Task['start'].execute()
  end
  
  it 'should send job to queue' do
    Rake::Task['test:mine[%s,%s]' % [user.username,user.password]].execute()
    
  end
end