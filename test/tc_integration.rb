# integration tests for copernicium modules

## TESTS NEEDED:
#  - Commit
#  - Checkout
#  - Making/Deleting Branches
#  - Merging
#  - Status
#  - Push
require "byebug"
require_relative "test_helper"

include Copernicium::Driver

class CoperniciumIntegrationTests < Minitest::Test
  describe "Integration" do
    def drive(string)
      Driver.run string.split
    end

    before "create a cn new repo to test" do
      Dir.mkdir("workspace")
      Dir.chdir("workspace")
      File.write("1.txt", "1")
      File.write("2.txt", "2")
      Workspace.create_project
      Workspace.setup
      drive "commit -m init"
      drive "branch -c dev"
    end

    after "delete the cn repo and the workspace" do
      Dir.chdir(File.join(Dir.pwd, ".."))
      FileUtils.rm_rf("workspace")
    end

    it "can commit changes" do
      File.write "1.txt", "1_1"
      File.write "2.txt", "2_2"
      drive "commit -m another"
      Repos.history("dev").size.must_equal 2
      Repos.history("master").size.must_equal 1
    end

    it "can make a branch" do
      drive "branch test"
      Repos.history("test").wont_be_nil
    end

    it "can delete a branch" do
      drive "branch -d test"
      Repos.history("test").must_equal []
    end

    it "can check the status of the repository" do
      File.delete("2.txt")
      File.write("1.txt","edit")
      File.write("3.txt","3")
      Workspace.status.must_equal [["3.txt"],["1.txt"],["2.txt"]]
    end

    it "can checkout head" do
      File.write("1.txt","none")
      drive "checkout head"
      content = File.read("1.txt")
      content.must_equal "1"
    end

=begin
    it "can checkout a list of files" do
      File.write("1.txt","none")
      drive "checkout master 1.txt"
      content = File.read("1.txt")
      content.must_equal "1"
    end

    # Won"t work because clean not handled by UI yet
    it "can revert back to the last commit" do
      File.write("1.txt", "1_1")
      File.write("2.txt", "2_2")

      comm = drive("clean")
      Workspace.clean(comm)

      content = File.read("1.txt")
      content.must_equal "1"
      content = File.read("2.txt")
      content.must_equal "2"
    end

    # Won"t work because clean not handled by UI yet
    it "can clean specific files in the workspace" do
      File.write("1.txt", "1_1")
      File.write("2.txt", "2_2")

      comm = drive("clean 1.txt")
      Workspace.clean(comm)

      Workspace.File.read("1.txt").must_equal "1"
      Workspace.File.read("2.txt").must_equal "2_2"
    end

    it "can checkout a branch" do
      @ws.File.read("1.txt").must_equal "1"
      @ws.File.read("2.txt").must_equal "2"
      @ws.File.write("1.txt", "1_1")
      @ws.File.write("2.txt", "2_2")
      comm = drive("commit -m Test Commit")
      @ws.commit(comm)

      # Will work once checkout is completed
      comm = drive("checkout dev")
      @ws.checkout(comm)

      # Switch to dev, files should not be modified
      @ws.File.read("1.txt").must_equal "1"
      @ws.File.read("2.txt").must_equal "2"

    end

    ## Will flesh out merge, push, and pull once they
    # are fleshed out

    it "can merge two branches" do
      # Assuming currently on master branch, merge dev
      # make sure things work or something.
      comm = drive("merge dev")
      #@pushpull.UICommandParser(comm)
    end

    it "can push a branch" do
      #push branchname
      comm = drive("push dev")
    end

    it "can pull a branch" do
      #pull branchname
      comm = drive("pull origin dev")
    end
=end
  end
end

