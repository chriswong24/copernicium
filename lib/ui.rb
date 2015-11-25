# user interface module

module Copernicium
  # Function: parse_command()
  #
  # Parameters:
  #   * argv - an array containing the tokenized command line from the user
  #       For instance:
  #         "cn hello world" -> ['hello', 'world']
  #   * cmds - the text command line given by the user
  #   * actually should be an array of arguments, eg:
  #   * cn hello world -> ['hello', 'world']
  #
  # Return value:
  #   A UICommandCommunicator object containing details of the command to be
  #   executed by the respective backend module.
  #
  def parse_command(cmds)

    # handle no arguments given - show help information
    # TODO

    %w{init status push pull}.each do |noarg| # Handle no-argument commands
      if cmds.first == noarg
        first = cmds.shift
        return UICommandCommunicator.new(command: first, opts: cmds)
      end
    end

    # Handle "commit"
    if cmds.first == "commit"
      messflag = cmds.find_index("-m")
      if (messflag.nil?)
        print "Error: commit message is empty"
        # TODO: launch editor and get long commit message
        # alternatively just prompt them for a commit message
        # using rubys 'gets', and use that as the message
        # refactor this into single method, use below
        return nil
      end

      # mash everything after the -m flag into a single string
      message = cmds[messflag+1..-1].join ' '

      if message == '' || message.nil?
        print "Error: commit message is empty"
        # TODO: launch editor and get long commit message
        # alternatively just prompt them for a commit message
        # using rubys 'gets', and use that as the message
        return nil
      end

      return UICommandCommunicator.new(command: "commit",
                                       commit_message: message)
    end

    # Handle "merge"
    if cmds.start_with? "merge"
      cmd_split = cmd.split(" ")

      if cmd_split.count != 2
        print "Error: too many/few arguments to command 'merge'! Please specify a single commit to merge into the current branch.\n"
        return nil
      end

      return UICommandCommunicator.new(command: "merge", rev: cmd_split[1])
    end

    # Handle "checkout"
    if cmds.start_with? "checkout"
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
    if cmds.start_with? "clone"
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
    attr_reader :command, :arguments, :files, :rev, :commit_message, :repo
    # Types of arguments:
    # files    -  An array of one or more file paths
    # rev      - A single revision indicator (commit #, branch name, HEAD, etc.)
    # repo     - URL/path to a remote repository
    # commit_message - A commit message
    def initialize(command: nil, files: nil, rev: nil,
                   commit_message: nil, repo: nil, opts: nil)
      @commit_message = commit_message
      @command = command
      @files = files
      @opts = opts
      @repo = repo
      @rev = rev
    end
  end
end
