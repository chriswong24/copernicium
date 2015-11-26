# user interface module

module Copernicium
  # Function: run()
  #   * execute a string command, wrapper around parse command
  def run(string)
    parse_command string.split
  end

  # Function: parse_command()
  #
  # Parameters:
  #   * args - an array containing the tokenized command line from the user
  #       For instance: "cn hello world" -> ['hello', 'world']
  #
  # Return value:
  #   A UICommandCommunicator object containing details of the command to be
  #   executed by the respective backend module.
  #
  def parse_command(args)

    # TODO handle no arguments given - show help information

    %w{init status push pull}.each do |noarg| # Handle no-argument commands
      if args.first == noarg
        first = args.shift
        return UICommandCommunicator.new(command: first, opts: args)
      end
    end

    if args.first == "commit" # Handle commit
      return parse_commit args
    end

    if args.first == "checkout" # Handle checkout
      return parse_checkout args
    end

    if args.first == "merge" # Handle merge
      return parse_merge args
    end

    if args.first == "clone" # Handle clone
      cmd_split = cmd.split(" ")

      if cmd_split.count != 2
        print "Error: wrong number of arguments to command 'clone'! Please specify a single remote repository to clone.\n"
        return nil
      end

      return UICommandCommunicator.new(command: "clone", repo: cmd_split[1])
    end
  end

  def parse_commit(args)
    messflag = args.find_index("-m")
    message = get_message if (messflag.nil?)

    # mash everything after the -m flag into a single string
    message = args[messflag + 1..-1].join ' '

    # if nothing is there after the -m flag, prompt for mess
    message = get_message if (message == '' || message.nil?)

    return UICommandCommunicator.new(command: "commit", commit_message: message)
  end

  def parse_checkout(args)
    if args.length < 2
      # todo allow user to give the checkout instead of dying
      puts "Error: no branch or revision given to checkout"
      return nil
    end

    if args.length == 2 # No file names given - check out all files in revision
      return UICommandCommunicator.new(command: "checkout", rev: args[1])
    end

    # Else we should only checkout the specified file(s) from the given revision
    files = args[2..-1] # get all elements after checkout
    return UICommandCommunicator.new(command: "checkout",
                                     rev: args[1], files: files)
  end

  def parse_merge(args)
    if args.length > 2
      puts 'Error: too many/few arguments to merge'
      puts 'Please specify a single commit to merge into the current branch.'
      # perhaps optionally query to get the single commit
      return nil
    end

    args.shift # remove merge from args
    return UICommandCommunicator.new(command: "merge", rev: args.first)
  end

  def get_message # havent tested this...
    puts "No commit message (-m) specified. Please enter a commit message:"
    gets # read a line from user, and return it
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
