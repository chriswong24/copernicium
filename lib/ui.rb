# user interface module - parse and execute commands
# integrates all modules, central module


VERSION = "0.0.1"

module Copernicium
  class Driver
    # Get some info from the user when they dont specify it
    def get(info)
      puts "Hi, #{info} not specified. Enter #{info}:"
      gets.chomp # read a line from user, and return it
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
      pexit HELP_BANNER, 0 if args.first == '-h'

      # if -v flag givem show version
      pexit VERSION, 0 if args.first == '-v'

      # Handle standard commands
      case args.shift
      when 'init'
        init args
      when 'status'
        status args
      when 'clone'
        clone args
      when 'commit'
        commit args
      when 'checkout'
        checkout args
      when 'merge'
        merge args
      when 'push'
        push args
      when 'pull'
        pull args
      else # handle an unrecognized argument, show help and exit
        pexit "Unrecognized command #{args.first}\n" + HELP_BANNER, 1
      end
    end # run

    def init(args)
      UIComm.new(command: 'init', opts: args)
      # todo - make call to repos to create repo
    end

    def status(args)
      UIComm.new(command: 'status', opts: args)
      # todo - make call to workspace, get and show status
    end

    def push(args)
      UIComm.new(command: 'push', opts: args)
      # todo - make call to pushpull, push remote
    end

    def pull(args)
      UIComm.new(command: 'pull', opts: args)
      # todo - make call to pushpull, pull remote
    end

    def checkout(args)
      if args.empty?
        rev = get 'branch or revision'
      else
        rev = args.shift
        files = args
        end

        # todo - call repos checkout the given / branch
        # todo - also, figure out if is branch or rev id
        # this can be done by checking if it is a branch, and if not, then just
        # assume it is a rev id. if it isnt, then something will break :/

        UIComm.new(command: 'checkout', rev: rev, files: files)
      end

      def clone(args)
        # todo - optionally check for folder to clone into, instead of cwd
        if args.empty?
          repo = get 'repo url to clone'
        else
          repo = args.first
        end

        # todo - actually clone remote locally

        UIComm.new(command: 'clone', repo: repo)
      end

      def commit(args)
        # todo parse file list, in case just commiting some files

        messflag = args.find_index('-m')
        message = get 'commit message' if (messflag.nil?)

        # mash everything after the -m flag into a single string
        message = args[messflag + 1..-1].join ' '

        # if nothing is there after the -m flag, prompt for mess
        message = get 'commit message' if (message == '' || message.nil?)

        UIComm.new(command: 'commit', commit_message: message)
      end

      def merge(args)
        if args.empty?
          puts 'I need a commit to merge.'
          rev = get 'single commit to merge'
        else # use given
          rev = args.first
        end

        # todo - call repos merge command

        UIComm.new(command: 'merge', rev: rev)
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
