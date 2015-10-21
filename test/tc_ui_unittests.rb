############################################################
# Ethan J. Johnson
# CSC 453: Dynamic Languages and Software Development
# University of Rochester, Fall 2015
#
# DVCS Project - Preliminary unit tests for UI module
# October 15, 2015
############################################################

require 'test_helper'

class TestUI < Minitest::Test

  describe "UIModule" do
    
    it "supports 'init' command" do
      comm = parse_command "init"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "init"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'add' command" do
      comm = parse_command "add test.txt"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "add"
      comm.files.must_equal ["test.txt"]
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end
    
    it "supports 'addremove' command" do
      comm = parse_command "addremove"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "addremove"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'forget' command" do
      comm = parse_command "forget test.txt"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "forget"
      comm.files.must_equal ["test.txt"]
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'remove' command" do
      comm = parse_command "remove test.txt"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "remove"
      comm.files.must_equal ["test.txt"]
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'update' command" do
      # The revision indicator parameter is optional
      comm = parse_command "update"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "update"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil

      comm = parse_command "update tip"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "update"
      comm.files.must_be_nil
      comm.rev.must_equal "tip"
      comm.commit_message.must_be_nil
    end

    it "supports 'revert' command" do
      # The file name parameters are optional
      comm = parse_command "revert" # Undo all uncommitted changes
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "revert"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil

      comm = parse_command "revert test.txt foo.c" # Undo changes to these files
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "revert"
      comm.files.must_equal ["test.txt", "foo.c"]
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'diff' command" do
      # The file name parameters are optional
      comm = parse_command "diff" # Show all changes since last commit
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "diff"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil

      comm = parse_command "diff test.txt foo.c" # Show changes only in these files
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "diff"
      comm.files.must_equal ["test.txt", "foo.c"]
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'status' command" do
      comm = parse_command "status"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "status"
      comm.files.must_be_nil
      comm.rev.must_be_nil
      comm.commit_message.must_be_nil
    end

    it "supports 'log' command" do
      comm = parse_command "log"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "log"
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

    it "supports 'incoming' command" do
      comm = parse_command "incoming"
      comm.must_be_instance_of UICommandCommunicator
      comm.command.must_equal "incoming"
      comm.files.must_be_nil
      comm.rev.must_be_nil
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

# Communication object that will pass commands to backend modules
class UICommandCommunicator

  attr_reader :command
  
  # Types of arguments - different fields will be set depending on the command
  attr_reader :files # An array of one or more file paths
  attr_reader :rev # A single revision indicator (commit #, branch name, HEAD, tip, etc.)
  attr_reader :commit_message # A commit message

  def initialize(command: nil, files: nil, rev: nil, commit_message: nil)
    @command = command
    @files = files
    @rev = rev
    @commit_message = commit_message
  end
end

def parse_command(cmd)
  return UICommandCommunicator.new
end

