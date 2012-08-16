require 'configuration'
require 'tasks'
require 'sidekiq/testing'


describe "Workers" do

	before :each do
		@credentials = { login: 'fir3', password: 'f403b0755e1edb2b6e3cd7bc443bf4dc' }
		@operation_id = Random.new.rand(1..1000000)
	end
	describe LJImport do
		it "queue job for importing posts and having at least one full post" do
			LJImport.perform_async(@operation_id, @credentials[:login], @credentials[:password])
			puts LJImport.jobs
		end
	end

	describe LJPost do
		it "queues for getting single post" do
		  LJPost.perform_async()
		end
	end

	describe LJAccess do
		it "queue job for getting session" do
		  LJAccess.perform_async()
		end
	end

	describe LJUpdate do
		it "queue job for updating journal since some time" do
		  LJUpdate.perform_async()
		end
	end
end