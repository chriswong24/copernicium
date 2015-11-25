# user interface module

module Copernicium
  # Function: parse_command()
  #
  # Parameters:
  #   * argv - an array containing the tokenized command line from the user
  #       For instance:
  #         "cn hello world" -> ['hello', 'world']
  #
  # Return value:
  #   A UICommandCommunicator object containing details of the command to be
  #   executed by the respective backend module.
  #
  def parse_command(argv)
    #
    # Convert the array of arguments to a space-separated string (i.e., as it
    # would actually be entered on the command line). This makes it easier to
    # parse some commands, such as commit messages given with "commit -m".
    #
    # (Some of the commands could probably be more easily parsed by dealing
    # directly, with argv, i.e., I'm just splitting them back up, but I've
    # already written the code and it's most important to get it working. This
    # can be refactored later if we have time, but in the meantime, it should
    # be sound, if slightly roundabout.)
    #
    cmd = ""
    argv.each do |arg|
      cmd << arg
      cmd << " "
    end
    cmd.chop! # Remove extra space at the end
    
    # Handle no-argument commands
    if cmd == "init" or cmd == "status" or cmd == "push" or cmd == "pull"
      return UICommandCommunicator.new(command: cmd)
    end

    # Handle "commit"
    if cmd.start_with? "commit"
      cmd_message_split = cmd.partition(" -m ")

      if cmd_message_split.count != 3 or cmd_message_split[2] == ""
        print "Error: no commit message (or multiple messages) given for command 'commit'!\n"
        return nil
      end

      commit_msg = cmd_message_split[2]

      if commit_msg.length == 0
        print "Error: commit message is empty"
        # TODO: launch editor and get long commit message
        return nil
      end

      # Filter quotes around the commit message, if present
      # (If the quotes around the commit message do not match, we will not filter them, i.e.,
      # they'll be considered an intentional part of the message.)
      if (commit_msg[0] == '"' and commit_msg[commit_msg.length - 1] == '"') \
        or (commit_msg[0] == "'" and commit_msg[commit_msg.length - 1] == "'")

        commit_msg = commit_msg.slice(1, commit_msg.length - 2)
      end

      return UICommandCommunicator.new(command: "commit", commit_message: commit_msg)
    end

    # Handle "merge"
    if cmd.start_with? "merge"
      cmd_split = cmd.split(" ")

      if cmd_split.count != 2
        print "Error: too many/few arguments to command 'merge'! Please specify a single commit to merge into the current branch.\n"
        return nil
      end

      return UICommandCommunicator.new(command: "merge", rev: cmd_split[1])
    end

    # Handle "checkout"
    if cmd.start_with? "checkout"
      cmd_split = cmd.split(" ")

      if cmd_split.count < 2
        print "Error: no branch or revision specified to command 'checkout'!\n"
        return nil
      end

      if cmd_split.count == 2
        # No file names given - check out all files at the given revision
        return UICommandCommunicator.new(command: "checkout", rev: cmd_split[1])
      end

      # Else, we should only checkout the specified file(s) from the given revision.
      return UICommandCommunicator.new(command: "checkout", rev: cmd_split[1], files: cmd_split[2..(cmd_split.count - 1)])
    end

    # Handle "clone"
    if cmd.start_with? "clone"
      cmd_split = cmd.split(" ")

      if cmd_split.count != 2
        print "Error: wrong number of arguments to command 'clone'! Please specify a single remote repository to clone.\n"
        return nil
      end

      return UICommandCommunicator.new(command: "clone", repo: cmd_split[1])
    end
  end

  # Communication object that will pass commands to backend modules
  class UICommandCommunicator

    attr_reader :command

    # Types of arguments - different fields will be set depending on the command
    attr_accessor :files # An array of one or more file paths
    attr_accessor :rev # A single revision indicator (commit #, branch name, HEAD, tip, etc.)
    attr_accessor :commit_message # A commit message
    attr_accessor :repo # URL/path to a remote repository

    def initialize(command: nil, files: nil, rev: nil, commit_message: nil, repo: nil)
      @command = command
      @files = files
      @rev = rev
      @commit_message = commit_message
      @repo = repo
    end
  end
end
