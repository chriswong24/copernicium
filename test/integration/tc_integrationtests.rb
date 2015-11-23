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
		before "Calling basic copernicium commands" do
			@inst = Copernicium::PushPull.new
			@workspace = Workspace::Workspace.new(Dir.pwd)
			@repo = Repos::Repos.new()
			@RevLog = Copernicium::RevLog.new(Dir.pwd)


			#Create two branches, master and dev



		end

		it "can initialize the repository" do
			comm = parse_command("init")
			#@repo.initialize(comm)


			#initialize reposotiry(comm)

		end

		it "can checkout a branch" do
			#assert @workspace.branch_name == "master"
			comm = parse_command("checkout")

			#assert master = file list
			#assert test_dev = file list + test file
		end

		it "can commit changes" do

			@repo.manifest.size.must_equal 0

			@workspace.writeFile("1.txt", "1")
     	@workspace.writeFile("2.txt", "2")
			comm = parse_command("commit -m \"Test Commit\"")
			@workspace.commit(comm)

			#assert manifest.size > 0 ?

			#assert filelist= ["1.txt","2.txt"]
		end

		it "can merge two branches" do
			comm = parse_command("merge")
			#assert master = file list
			#assert test_dev = file list + test file

		end

		it "can push a branch" do
			comm = parse_command("push")
		end

		it "can pull a branch" do
			comm = parse_command("pull")
		end

		it "can check the status of the repository" do
			comm = parse_command("status")

		end

	end
		
end
