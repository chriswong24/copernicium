############################################################
# Ethan J. Johnson
# CSC 453: Dynamic Languages and Software Development
# University of Rochester, Fall 2015
#
# DVCS Project - Preliminary unit tests for UI module
# October 15, 2015
############################################################


require_relative 'test_helper'
include Copernicium


class TestUI < Minitest::Test
  describe "UIModule" do

    def ui_test_helper(comm, cmd, files=nil, rev=nil, msg=nil, repo=nil)
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal cmd
      comm.files.must_equal files
      comm.rev.must_equal rev
      comm.commit_message.must_equal msg
      comm.repo.must_equal repo
    end

    it "supports 'init' command" do
      comm = parse_command ["init"]
      ui_test_helper(comm, "init")
    end

    it "supports 'status' command" do
      comm = parse_command ["status"]
      ui_test_helper(comm, "status")
    end

    # -m is optional, but if the user doesn't give it, the UI will prompt for
    # a message in an editor. Thus, the UICommandCommunicator will always
    # include a commit message.
    it "supports 'commit' command" do
      comm = parse_command %w{commit -m a commit message}
      ui_test_helper(comm, "commit", nil, nil, "a commit message")

      comm = parse_command %w{commit -m a \strange commit $message}
      ui_test_helper(comm, "commit", nil, nil, 'a \strange commit $message')
    end

    # Two valid forms of "checkout" command:
    # cn checkout revision (checks out full repo at revision)
    # cn checkout revision file.txt (checks out only the specified files
    # from revision)
    #it "supports 'checkout' command" do
      #comm = parse_command "checkout revID"
      #ui_test_helper(comm, "checkout", nil, "revID")

      #comm = parse_command "checkout revID file.txt"
      #ui_test_helper(comm, "checkout", ["file.txt"], "revID")

      #comm = parse_command "checkout revID file.txt foo.c"
      #ui_test_helper(comm, "checkout", ["file.txt", "foo.c"], "revID")
    #end

    #it "supports 'pull' command" do
    #comm = parse_command "pull"
    #comm.must_be_instance_of UICommandCommunicator
    #comm.command.must_equal "pull"
    #comm.files.must_be_nil
    #comm.rev.must_be_nil
    #comm.commit_message.must_be_nil
    #end

    #it "supports 'push' command" do
    #comm = parse_command "push"
    #comm.must_be_instance_of UICommandCommunicator
    #comm.command.must_equal "push"
    #comm.files.must_be_nil
    #comm.rev.must_be_nil
    #comm.commit_message.must_be_nil
    #end

    #it "supports 'merge' command" do
    #comm = parse_command "merge some_revision" # Merge some_revision into current branch
    #comm.must_be_instance_of UICommandCommunicator
    #comm.command.must_equal "merge"
    #comm.files.must_be_nil
    #comm.rev.must_equal "some_revision"
    #comm.commit_message.must_be_nil
    #end

    #it "supports 'clone' command" do
    ## Format:
    ##   cn clone path-to-remote-repository
    #comm = parse_command "clone ssh://user@some-host.com/some/repo/path"
    #ui_test_helper(comm, "clone", nil, nil, nil, "ssh://user@some-host.com/some/repo/path")
    #end
  end
end

