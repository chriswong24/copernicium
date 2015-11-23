require 'minitest/spec'
require 'minitest/autorun'

# Temporary until we fix module names
#require_relative '../../lib/workspace.rb'
require_relative '../../lib/ui.rb'
require_relative '../../lib/pushpull.rb'
require_relative '../../lib/repos.rb'
require_relative '../../lib/RevLog.rb'

include Copernicium


class CoperniciumIntegrationTests < Minitest::Test
	describe "CoperniciumDVCS" do
		before "Initializing the moduels" do
			@inst = Copernicium::PushPull.new
			#@workspace = Workspace::Workspace.new(Dir.pwd)
			@repo = Repos::Repos.new()
			@RevLog = Copernicium::RevLog.new(Dir.pwd)


		end

		it "can initialize the repository" do
			comm = parse_command("init")
			comm.must_be_instance_of UICommandCommunicator
		end

		it "can checkout a branch" do

		end

		it "can commit changes" do

		end

		it "can merge two branches" do

		end

		it "can push a branch" do

		end

		it "can pull a branch" do

		end

		it "can check the status of the repository" do

		end

		#cn init
		#cn checkout
		#cn commit
		#cn branch
		#cn merge
		#cn push
		#cn pull
		#cn status

	end
		
end
