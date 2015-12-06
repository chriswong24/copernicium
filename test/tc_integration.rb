# integration tests for copernicium modules

## TESTS NEEDED:
#  - Commit
#  - Checkout
#  - Making/Deleting Branches
#  - Merging
#  - Status
#  - Push


require_relative "test_helper"
require 'byebug'

include Copernicium::Driver

# For testing purposes?  Perhaps implement in Repos later
module Repos
  def get_branch(bname)
    @@branches[bname]
  end
end


class CoperniciumIntegrationTests < Minitest::Test
  describe "IntegrationTesting" do
    def runner(string)
      Driver.setup
      Driver.run string.split
    end

    before "Calling basic copernicium commands" do
      #@pushpull = Copernicium::PushPull.new

      Workspace.setup

      Dir.mkdir("workspace")
      #initial commit?
      Copernicium.writeFile("workspace/1.txt", "1")
      Copernicium.writeFile("workspace/2.txt", "2")
      comm = runner("commit -m Test Commit")
      Repos.make_branch("dev")
    end

    after "running integration tests" do
      FileUtils.rm_rf('workspace')
      FileUtils.rm_rf('.cn')
    end

    it "can commit changes" do
      Repos.get_branch("master").size.must_equal 1
      Copernicium.writeFile("workspace/1.txt", "1_1")
      Copernicium.writeFile("workspace/2.txt", "2_2")
      comm = runner("commit -m Test Commit")
      Workspace.commit(comm)
      Repos.get_branch("master").size.must_equal 2

      #todo : make sure commit written to disk
    end

    it "can make and delete a branch" do
      comm = runner("branch test")
      Repos.get_branch("test").wont_be_nil

      comm = runner("branch -d test")
      Repos.get_branch("test").must_be_nil
    end
=begin
    # Won't work because clean not handled by UI yet
    it "can revert back to the last commit" do
      Copernicium.writeFile("workspace/1.txt", "1_1")
      Copernicium.writeFile("workspace/2.txt", "2_2")

      comm = runner("clean")
      Workspace.clean(comm)

      content = Copernicium.readFile("workspace/1.txt")
      content.must_equal "1"
      content = Copernicium.readFile("workspace/2.txt")
      content.must_equal "2"
    end

    # Won't work because clean not handled by UI yet
    it "can clean specific files in the workspace" do
      Copernicium.writeFile("workspace/1.txt", "1_1")
      Copernicium.writeFile("workspace/2.txt", "2_2")

      comm = runner("clean workspace/1.txt")
      Workspace.clean(comm)

      Workspace.readFile("workspace/1.txt").must_equal "1"
      Workspace.readFile("workspace/2.txt").must_equal "2_2"
    end

    it "can check the status of the repository" do
      File.delete('workspace/2.txt')
      @ws.writeFile("workspace/1.txt","edit")
      @ws.writeFile("workspace/3.txt","3")

      comm = runner("status")
      changedFiles = @ws.status(comm)
      changedFiles.must_equal([["workspace/3.txt"],["workspace/1.txt"],["workspace/2.txt"]])
    end

    it "can checkout a branch" do
      @ws.readFile("workspace/1.txt").must_equal "1"
      @ws.readFile("workspace/2.txt").must_equal "2"
      @ws.writeFile("workspace/1.txt", "1_1")
      @ws.writeFile("workspace/2.txt", "2_2")
      comm = runner("commit -m Test Commit")
      @ws.commit(comm)

      # Will work once checkout is completed
      comm = runner("checkout dev")
      @ws.checkout(comm)

      # Switch to dev, files should not be modified
      @ws.readFile("workspace/1.txt").must_equal "1"
      @ws.readFile("workspace/2.txt").must_equal "2"

    end

    it "can checkout a list of files" do
      @ws.writeFile("workspace/1.txt","none")
      comm = runner("checkout master ./workspace/1.txt")
      @ws.checkout(comm)

      content = @ws.readFile("workspace/1.txt")
      content.must_equal "1"
    end

    ## Will flesh out merge, push, and pull once they
    # are fleshed out

    it "can merge two branches" do
      # Assuming currently on master branch, merge dev
      # make sure things work or something.
      comm = runner("merge dev")
      #@pushpull.UICommandParser(comm)
    end

    it "can push a branch" do
      #push branchname
      comm = runner("push dev")
    end

    it "can pull a branch" do
      #pull branchname
      comm = runner("pull origin dev")
    end
=end
  end
end

