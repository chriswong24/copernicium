############################################################
# Ethan J. Johnson
# CSC 453: Dynamic Languages and Software Development
# University of Rochester, Fall 2015
#
# DVCS Project - Preliminary unit tests for UI module
# October 15, 2015
############################################################


require_relative 'test_helper'


class TestUI < Minitest::Test
  describe "UIModule" do

    before "checking ui performance, create driver" do
      @driver = Driver.new
    end

    def ui_test_helper(comm, cmd, files=nil, rev=nil, msg=nil, repo=nil)
      comm.must_be_instance_of UIComm
      comm.command.must_equal cmd
      comm.files.must_equal files
      comm.rev.must_equal rev
      comm.commit_message.must_equal msg
      comm.repo.must_equal repo
    end

    it "supports 'init' command" do
      comm = @driver.run ["init"]
      ui_test_helper(comm, "init")
    end

    it "supports 'status' command" do
      comm = @driver.run ["status"]
      ui_test_helper(comm, "status")
    end

    # -m is optional, but if the user doesn't give it, the UI will prompt for
    # a message in an editor. Thus, the UICommandCommunicator will always
    # include a commit message.
    it "supports 'commit' command" do
      comm = @driver.run %w{commit -m a commit message}
      ui_test_helper(comm, "commit", nil, nil, "a commit message")

      comm = @driver.run %w{commit -m a \strange commit $message}
      ui_test_helper(comm, "commit", nil, nil, 'a \strange commit $message')
    end

    # Two valid forms of "checkout" command:
    # cn checkout revision (checks out full repo at revision)
    # cn checkout revision file.txt (checks out only the specified files
    # from revision)
    it "supports 'checkout' command" do
      comm = @driver.run %w{checkout revID}
      ui_test_helper(comm, "checkout", nil, "revID")

      comm = @driver.run %w{checkout revID file.txt}
      ui_test_helper(comm, "checkout", ["file.txt"], "revID")

      comm = @driver.run %w{checkout revID file.txt foo.c}
      ui_test_helper(comm, "checkout", ["file.txt", "foo.c"], "revID")
    end

    it "supports 'pull' command" do
      comm = @driver.run ["pull"]
      ui_test_helper(comm, "pull")
    end

    it "supports 'push' command" do
      comm = @driver.run ["push"]
      ui_test_helper(comm, "push")
    end

    it "supports 'merge' command" do # Merge some_revision into current branch
      comm = @driver.run %w{merge some_revision}
      ui_test_helper(comm, "merge", nil, "some_revision")
    end

    # Format: cn clone path-to-remote-repository
    it "supports 'clone' command" do
      # todo make cloning work haha
      #host = "ssh://user@some-host.com/some/repo/path"
      #comm = @driver.run "clone " + host
      #ui_test_helper(comm, "clone", nil, nil, nil, host)
    end
  end
end

