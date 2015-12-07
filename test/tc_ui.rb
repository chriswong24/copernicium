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
    def ui_test_helper(comm, cmd, files=nil, rev=nil, msg=nil, repo=nil)
      comm.must_be_instance_of UIComm
      comm.command.must_equal cmd
      comm.files.must_equal files
      comm.rev.must_equal rev
      comm.cmt_msg.must_equal msg
      comm.repo.must_equal repo
    end

    it "supports 'init' command" do
      comm = Driver.run ["init"]
      ui_test_helper(comm, "init")
    end

    it "supports 'status' command" do
      comm = Driver.run ["status"]
      ui_test_helper(comm, "status")
    end

    it "supports 'history' command" do
      Driver.run ["history"]
    end

    it "supports 'branch' command" do
      Driver.run ["branch"]

      Driver.run %w{branch -c newbranch}

      Driver.run %w{branch -r renamedbranch}

      Driver.run %w{branch -d renamedbranch}

      Driver.run %w{branch -d nonexistentbranch}

      Driver.run %w{branch -c branch1}
      Driver.run %w{branch -c branch2}
      Driver.run %w{branch branch1} # Switch branch

      Driver.run %w{branch thirdbranch} # Create new branch without -c
    end

    it "supports 'clean' command" do
      Driver.run ["clean"]
    end

    # -m is optional, but if the user doesn't give it, the UI will prompt for
    # a message from command line. Thus, the UICommandCommunicator will always
    # include a commit message.
    it "supports 'commit' command" do
      comm = Driver.run %w{commit -m a commit message}
      ui_test_helper(comm, "commit", nil, nil, "a commit message")

      comm = Driver.run %w{commit -m a \strange commit $message}
      ui_test_helper(comm, "commit", nil, nil, 'a \strange commit $message')
    end

    # Two valid forms of "checkout" command:
    # cn checkout revision (checks out full repo at revision)
    #
    # Putting this one on hold for now:
    # cn checkout revision file.txt (checks out only the specified files
    # from revision)
    it "supports 'checkout' command" do
      comm = Driver.run %w{checkout revID}
      ui_test_helper(comm, "checkout", [], "revID")

      comm = Driver.run %w{checkout revID file.txt}
      ui_test_helper(comm, "checkout", ["file.txt"], "revID")

      comm = Driver.run %w{checkout revID file.txt foo.c}
      ui_test_helper(comm, "checkout", ["file.txt", "foo.c"], "revID")
    end

    it "supports 'merge' command" do
      Driver.run %w{branch -c branch1}
      Driver.run %w{branch -c branch2}
      Driver.run %w{merge branch1}
    end

    it "supports 'pull' command" do
      comm = Driver.run ["pull"]
      ui_test_helper(comm, "pull")
    end

    it "supports 'push' command" do
      comm = Driver.run ["push"]
      ui_test_helper(comm, "push")
    end

    # Format: cn clone <user> <repo.host:/dir/of/repo>
    it "supports 'clone' command" do
      # todo make cloning work haha
      #host = "ssh://user@some-host.com/some/repo/path"
      #comm = Driver.run "clone " + host
      #ui_test_helper(comm, "clone", nil, nil, nil, host)
    end
  end
end

