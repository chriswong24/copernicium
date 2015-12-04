require 'minitest/spec'
require 'minitest/autorun'
require_relative 'test_helper'


class Workspace
	attr_reader :repos, :files
end

class CoperniciumIntegrationTests < Minitest::Test
	describe "CoperniciumDVCS" do
		before "Calling basic copernicium commands" do

			@inst = Copernicium::PushPull.new
			@workspace = Copernicium::Workspace.new
			@workspace.repos.make_branch("dev")

			@workspace.writeFile("workspace/1.txt","1")
      @workspace.writeFile("workspace/2.txt", "2")
      @workspace.commit(["workspace/1.txt","workspace/2.txt"])

		end

		it "can initialize the repository" do
			comm = parse_command("init")

		end

		it "can commit changes" do

			@workspace.repos.manifest["default"].size.must_equal 1
			@workspace.writeFile("1.txt", "1_1")
     	@workspace.writeFile("2.txt", "2_2")
			comm = parse_command("commit -m \"Test Commit\"")

			# Will include this once we start using UICommandCommunicator

			#@workspace.commit(comm).must_be_instance_of String
			#@workspace.repos.manifest.size.must_equal 1
		end

		it "can checkout a list of files" do
			comm = parse_command("checkout")
		end

		it "can checkout a branch" do

			@workspace.readFile("workspace/1.txt").must_equal "1"
			@workspace.readFile("workspace/2.txt").must_equal "2"
			@workspace.writeFile("workspace/1.txt", "1_1")
			@workspace.writeFile("workspace/2.txt", "2_2")
			@workspace.commit(["workspace/1.txt","workspace/2.txt"])

			comm = parse_command("checkout dev")
			#@workspace.checkout(comm)
			@workspace.checkout("dev")
			@workspace.readFile("workspace/1.txt").must_equal "1"
			@workspace.readFile("workspace/2.txt").must_equal "2"
			
		end

		it "can merge two branches" do
			comm = parse_command("merge")

		end

		it "can push a branch" do
			#push branchname
			comm = parse_command("push")
		end

		it "can pull a branch" do
			#pull branchname
			comm = parse_command("pull")
		end

		# Probably will delete this test because doesn't require any modular communication

		it "can check the status of the repository" do

		 	File.delete('workspace/2.txt')
      @workspace.writeFile("workspace/1.txt","edit")
      @workspace.writeFile("workspace/3.txt","3")

      changedFiles = @workspace.status()
      changedFiles.must_equal([["workspace/3.txt"],["workspace/1.txt"],["workspace/2.txt"]])

			#comm = parse_command("status")

		end
	end
end