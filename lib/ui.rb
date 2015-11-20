# user interface module

module Copernicium
  # Function: parse_command()
  #
  # Parameters:
  #   * cmd - the text command line given by the user
  #
  # Return value:
  #   A UICommandCommunicator object containing details of the command to be
  #   executed by the respective backend module.
  #
  def parse_command(cmd)
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
end
