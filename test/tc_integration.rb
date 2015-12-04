# integration tests for copernicium modules

require_relative 'test_helper'

class Workspace
  attr_reader :repos, :files
end

class CoperniciumIntegrationTests < Minitest::Test
  describe "IntegrationTesting" do
    def runner(string)
      Copernicium::Driver.new.run string.split
    end

    before "Calling basic copernicium commands" do
      @pushpull = Copernicium::PushPull.new
      @ws = Copernicium::Workspace.new

      #initial commit?
      Dir.mkdir('workspace')
      @ws.writeFile("workspace/1.txt", "1")
      @ws.writeFile("workspace/2.txt", "2")
      comm = runner("commit -m Test Commit")
      @ws.commit(comm)
      @ws.repos.make_branch("dev")
    end

    after "running integration tests" do
      FileUtils.rm_rf('workspace')
    end

    it "can commit changes" do
      @ws.repos.snaps["master"].size.must_equal 1
      @ws.writeFile("workspace/1.txt", "1_1")
      @ws.writeFile("workspace/2.txt", "2_2")

      comm = runner("commit -m Test Commit")
      @ws.commit(comm)

      @ws.readFile("workspace/1.txt").must_equal "1_1"
      @ws.readFile("workspace/2.txt").must_equal "2_2"
      @ws.repos.snaps["master"].size.must_equal 2
    end
=begin
    # Won't work because clean not handled by UI yet
    it "can revert back to the last commit" do
      @ws.writeFile("workspace/1.txt", "1_1")
      @ws.writeFile("workspace/2.txt", "2_2")

      comm = runner("clean")
      @ws.clean(comm)

      content = @ws.readFile("workspace/1.txt")
      content.must_equal "1"
      content = @ws.readFile("workspace/2.txt")
      content.must_equal "2"
    end

    # Won't work because clean not handled by UI yet
    it "can clean specific files in the workspace" do
      @ws.writeFile("workspace/1.txt", "1_1")
      @ws.writeFile("workspace/2.txt", "2_2")

      comm = runner("clean workspace/1.txt")
      @ws.clean(comm)

      @ws.readFile("workspace/1.txt").must_equal "1"
      @ws.readFile("workspace/2.txt").must_equal "2_2"
    end

    # Tests don't work because branch handling not complete
    it "can make and delete a branch" do
      comm = runner("branch test")
      @ws.repos.make_branch("test")
      @ws.repos.manifest["test"].wont_be_nil
      @ws.repos.manifest.size.must_equal 3
      @ws.repos.manifest["master"].wont_be_nil

      comm = runner("branch -d test")
      @ws.repos.delete_branch("test")
      @ws.repos.manifest["test"].must_be_nil
      @ws.repos.manifest["master"].wont_be_nil
      @ws.repos.manifest.size.must_equal 2
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

