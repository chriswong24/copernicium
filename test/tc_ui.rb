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

    def ui_test_helper(comm, cmd, files=nil, rev=nil, msg=nil)
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal cmd
      comm.files.must_equal files
      comm.rev.must_equal rev
      comm.commit_message.must_equal msg
    end

    it "supports 'init' command" do
      comm = parse_command "init"
      ui_test_helper('init')
    end

    it "supports 'status' command" do
      comm = parse_command "status"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "status"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'commit' command" do
      # -m is optional, but if the user doesn't give it, the UI will prompt for a message in an
      # editor. Thus, the UICommandCommunicator will always include a commit message.
      comm = parse_command "commit -m 'a commit message'"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "commit"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_equal "a commit message"
    end

    it "supports 'checkout' command" do
      # Three valid forms of "checkout" command:
      #   cn checkout revision              (checks out full repo at revision)
      #   cn checkout file.txt foo.c        (checks out file.txt and foo.c from the currently "active" revision)
      #   cn checkout revision file.txt     (checks out file.txt at revision)
      comm = parse_command "checkout master"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "checkout"
      comm.files.must_be_nil
      comm.rev.must_equal "master"
      comm.commit_message.must_be_nil

      comm = parse_command "checkout file.txt"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "checkout"
      comm.files.must_equal ["file.txt", "foo.c"]
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil

      comm = parse_command "checkout master file.txt"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "checkout"
      comm.files.must_equal ["file.txt"]
      comm.rev.must_equal "master"
      comm.commit_message.must_be_nil
    end

    it "supports 'pull' command" do
      comm = parse_command "pull"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "pull"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'push' command" do
      comm = parse_command "push"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "push"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'merge' command" do
      comm = parse_command "merge some_revision" # Merge some_revision into current branch
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "merge"
      comm.files.must_be_nil
      comm.rev.must_equal "some_revision"
      comm.commit_message.must_be_nil
    end

    it "supports 'clone' command" do
      # I'm thinking that "clone" might be best implemented purely in the UI: that is, it's
      # actually just a "wrapper command" that issues a series of more granular commands to the
      # backend. Specifically, it will need to:
      #   1. "init" an empty repo.
      #   2. Set the repo's remote to the place we're cloning from.
      #   3. "pull"
      #   4. "update"
      # This sequence of steps should accomplish the "clone" operation.
      #
      # At the moment, I can't really write a good spec for this since I'm not sure how remotes
      # will work. Since we're not trying to implement *all* the features/flexibility of Git and
      # Mercurial (just the "basics" to get a working, functional DVCS), we may not need to expose
      # a UI command like "git remote" - rather, the remote would be set automatically when
      # cloning, and a user could change remotes by editing the config file directly if needed
      # (which, frankly, is often what people end up doing for Git and Mercurial).

      # Just fail the test for now
      nil.must_equal "Test not yet implemented"
    end

  end
end

