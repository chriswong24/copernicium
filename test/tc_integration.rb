require 'minitest/spec'
require 'minitest/autorun'
require_relative 'test_helper'

class Workspace
	attr_reader :repos, :files
end

class CoperniciumIntegrationTests < Minitest::Test
	describe "CoperniciumDVCS" do
		before "Calling basic copernicium commands" do
			@pushpull = Copernicium::PushPull.new
			@workspace = Copernicium::Workspace.new

			#initial commit?
			@workspace.writeFile("workspace/1.txt", "1")
     	@workspace.writeFile("workspace/2.txt", "2")
     	comm = parse_command("commit -m Test Commit")
     	@workspace.commit(comm)
		end

		it "can commit changes" do
			@workspace.repos.manifest["default"].size.must_equal 1
			@workspace.writeFile("workspace/1.txt", "1_1")
     	@workspace.writeFile("workspace/2.txt", "2_2")

     	comm = parse_command("commit -m Test Commit")
			@workspace.commit(comm)

			@workspace.readFile("1.txt").must_equal "1_1"
			@workspace.readFile("2.txt").must_equal "2_2"
			@workspace.repos.manifest.size.must_equal 2
		end

		# Won't work because clean not handled by UI yet
		it "can revert back to the last commit" do
     	@workspace.writeFile("workspace/1.txt", "1_1")
     	@workspace.writeFile("workspace/2.txt", "2_2")

      comm = parse_command("clean")
      @workspace.clean(comm)

      content = @workspace.readFile("workspace/1.txt")
      content.must_equal "1"
      content = @workspace.readFile("workspace/2.txt")
      content.must_equal "2"
		end

		# Won't work because clean not handled by UI yet
		it "can clean specific files in the workspace" do
			@workspace.writeFile("workspace/1.txt", "1_1")
			@workspace.writeFile("workspace/2.txt", "2_2")

			comm = parse_command("clean workspace/1.txt") 
			@workspace.clean(comm)

			@workspace.readFile("workspace/1.txt").must_equal "1"
			@workspace.readFile("workspace/2.txt").must_equal "2_2"
		end

		# Tests don't work because branch handling not complete
		it "can make and delete a branch" do
			comm = parse_command("branch test")
			@workspace.UICommandParser(comm)
			@workspace.repos.manifest["test"].wont_be_nil

			comm = parse_command("branch -d test")
			@workspace.UICommandParser(comm)
			@workspace.repos.manifest["test"].must_be_nil
		end

		it "can check the status of the repository" do
		 	File.delete('workspace/2.txt')
      @workspace.writeFile("workspace/1.txt","edit")
      @workspace.writeFile("workspace/3.txt","3")

      comm = parse_command("status")
      changedFiles = @workspace.status(comm)
      changedFiles.must_equal([["workspace/3.txt"],["workspace/1.txt"],["workspace/2.txt"]])
		end

		it "can checkout a branch" do
			@workspace.readFile("workspace/1.txt").must_equal "1"
			@workspace.readFile("workspace/2.txt").must_equal "2"
			@workspace.writeFile("workspace/1.txt", "1_1")
			@workspace.writeFile("workspace/2.txt", "2_2")
			comm = parse_command("commit -m Test Commit")
			@workspace.commit(comm)

			comm = parse_command("checkout dev")
			@workspace.checkout(comm)

			# Switch to dev, files should not be modified
			@workspace.readFile("workspace/1.txt").must_equal "1"
			@workspace.readFile("workspace/2.txt").must_equal "2"
			
		end

		it "can checkout a list of files" do
			@workspace.writeFile("workspace/1.txt","none")
			comm = parse_command("checkout workspace/1.txt")
      @workspace.checkout(comm)

      content = @workspace.readFile("workspace/1.txt")
      content.must_equal "1"
		end

		## Will flesh out merge, push, and pull once they
		# are fleshed out

		it "can merge two branches" do
		# Assuming currently on master branch, merge dev
		# make sure things work or something.
		comm = parse_command("merge dev")
		@pushpull.UICommandParser(comm)

		end

		it "can push a branch" do
			#push branchname
			comm = parse_command("push dev")
		end

		it "can pull a branch" do
			#pull branchname
			comm = parse_command("pull origin dev")
		end

	end
end