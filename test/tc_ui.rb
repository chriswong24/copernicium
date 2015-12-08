############################################################
# Ethan J. Johnson
# CSC 453: Dynamic Languages and Software Development
# University of Rochester, Fall 2015
#
# DVCS Project - Preliminary unit tests for UI module
# October 15, 2015
############################################################


require_relative 'test_helper'

include Copernicium::Driver

class TestUI < Minitest::Test
  describe "UIModule" do
    def drive(str)
      Driver.run str.split
    end

    def ui_test_helper(comm, cmd, files=nil, rev=nil, msg=nil, repo=nil)
      comm.must_be_instance_of UIComm
      comm.command.must_equal cmd
      comm.files.must_equal files
      comm.rev.must_equal rev
      comm.cmt_msg.must_equal msg
      comm.repo.must_equal repo
    end

    it "supports 'init' command" do
      Driver.run ["init"]
    end

    it "supports 'status' command" do
      Driver.run ["status"]
    end

    it "supports 'history' command" do
      Driver.run ["history"]
    end

    it "supports 'branch' command" do
      drive "branch"
      drive 'branch -c newbranch'
      drive 'branch -r renamedbranch'
      drive 'branch -d renamedbranch'
      drive 'branch -d nonexistentbranch'
      drive 'branch -c branch1'
      drive 'branch -c branch2'
      drive 'branch branch1'
      # Create new branch without -c
      drive 'branch thirdbranch'
    end

    it "supports 'clean' command" do
      Driver.run ["clean"]
    end

    it "supports 'commit' command" do
      Driver.run %w{commit -m a commit message}
      Driver.run %w{commit -m a \strange commit $message}
    end

    it "supports 'checkout' command" do
      drive 'checkout master'
      drive 'branch -c newbranch'
      drive 'checkout master'
    end

    it "supports 'merge' command" do
      Driver.run %w{branch -c branch1}
      Driver.run %w{branch -c branch2}
      Driver.run %w{merge branch1}
    end

    # Format: cn clone <user> <repo.host:/dir/of/repo>
    # todo make cloning work haha
    it "supports 'clone' command" do
      host = "jwarn10@cycle1.csug.rochester.edu"
      comm = drive "clone " + host
      #ui_test_helper(comm, "clone", nil, nil, nil, host)
    end

=begin
    it "supports 'pull' command" do
      comm = Driver.run ["pull"]
      ui_test_helper(comm, "pull")
    end

    it "supports 'push' command" do
      comm = Driver.run ["push"]
      ui_test_helper(comm, "push")
    end
=end
  end
end

