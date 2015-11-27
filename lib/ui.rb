# user interface module - parse and execute commands
# integrates all modules, central module

VERSION = "0.0.1"

module Copernicium
  class Driver
    # Get some info from the user when they dont specify it
    def get(info)
      puts "Hi, #{info} not specified. Enter #{info}:"
      gets # read a line from user, and return it
    end

    # Print and exit with a specific code
    def pexit(msg, sig)
      puts msg
      exit sig
    end

    # Executes the required action for a given user command.
    #
    # Parameters:
    #   * args - an array containing the tokenized argv from the user
    #   For instance: "cn hello world" -> ['hello', 'world']
    #
    # Return value:
    #   A UIComm object containing details of the command to be
    #   executed by the respective backend module.
    #
    def run(args)

      # if no arguments given show help information
      pexit HELP_BANNER, 0 if args.empty?

      # if no arguments given show help information
      pexit HELP_BANNER, 0 if args.first == "-h"

      # if -v flag givem show version
      pexit VERSION, 0 if args.first == "-v"

      # Handle no-argument commands
      %w{init status push pull}.each do |noarg|
        if args.first == noarg
          first = args.shift
          return UIComm.new(command: first, opts: args)
        end
      end

      return commit args if args.first == "commit"
      return checkout args if args.first == "checkout"
      return merge args if args.first == "merge"
      return clone args if args.first == "clone"

      # handle an unrecognized argument, show help and exit
      pexit "Unrecognized command #{args.first}\n" + HELP_BANNER, 1
    end

    def checkout(args)
      if args.length < 2
        # todo allow user to give the checkout instead of dying
        puts "Error: no branch or revision given to checkout"
        return nil
      end

          # No file names given - check out all files in revision
      if args.length == 2
        return UIComm.new(command: "checkout", rev: args[1])
      end

      # Else only checkout the specified file(s) from the given revision
      files = args[2..-1] # get all elements after checkout command
      return UIComm.new(command: "checkout", rev: args[1], files: files)
    end

    def clone(args)
      if args.length != 2
        puts "Error: wrong number of arguments to clone"
        puts "Please specify a single remote repository to clone"
        return nil
      end

      return UIComm.new(command: "clone", repo: args[1])
    end

    def commit(args)
      messflag = args.find_index("-m")
      message = get_message if (messflag.nil?)

      # mash everything after the -m flag into a single string
      message = args[messflag + 1..-1].join ' '

      # if nothing is there after the -m flag, prompt for mess
      message = get_message if (message == '' || message.nil?)

      return UIComm.new(command: "commit", commit_message: message)
    end

    def merge(args)
      if args.length > 2
        puts 'Hi: too many/few arguments to merge'
        puts 'Please specify a single commit to merge into the current branch.'
        # perhaps optionally query to get the single commit
        return nil
      end

      args.shift # remove merge from args
      return UIComm.new(command: "merge", rev: args.first)
    end
  end

  # Communication object that will pass commands to backend modules
  # rev - A single revision indicator (commit #, branch name, HEAD, etc.)
  # repo - URL/path to a remote repository
  class UIComm
    attr_reader :command, :arguments, :files, :rev, :commit_message, :repo
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
