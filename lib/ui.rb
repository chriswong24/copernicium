# user interface module - parse and execute commands
# integrates all modules, central module


VERSION = "0.0.1"

module Copernicium
  # Print and exit with a specific code
  def pexit(msg, sig)
    puts msg
    exit sig
  end

  class Driver
    # Get some info from the user when they dont specify it
    def get(info)
      puts "Hi, #{info} not specified. Enter #{info}:"
      gets.chomp # read a line from user, and return it
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

      # get first command
      cmd = args.shift

      # if no arguments given show help information
      pexit COMMAND_BANNER, 0 if (cmd == '-h' || cmd == 'help')

      # if -v flag givem show version
      pexit VERSION, 0 if cmd == '-v'

      # Handle standard commands
      case cmd
      when 'init'
        init args
      when 'status'
        status args
      when 'branch'
        branch args
      when 'clean'
        clean args
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
        pexit "Unrecognized command #{cmd}\n" + COMMAND_BANNER, 1
      end
    end # run

    def init(args)
      ui = UIComm.new(command: 'init', opts: args)
      ws = Workspace.new(Dir.pwd)
      snap_id = Repos.new.make_snapshot
      ui
    end

    def status(args)
      UIComm.new(command: 'status', opts: args)
      # todo - make call to workspace, get and show status
    end

    def branch(args)
      # todo - switch branches, create branches
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

      # todo - also, figure out if is branch or rev id
      # this can be done by checking if it is a branch, and if not, then just
      # assume it is a rev id. if it isnt, then something will break :/

      # call workspace checkout the given / branch
      ui = UIComm.new(command: 'checkout', rev: rev, files: files)
      Workspace.new.checkout(ui)
      ui
    end

    def clean(args = [])
      ui = UIComm.new(command: 'clean', files: args)
      Workspace.new.clean(ui)
      ui
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
      messflag = args.find_index('-m')
      if messflag.nil?
        message = get 'commit message'
      else # mash everything after -m into a single string
        message = args[messflag + 1..-1].join ' '
      end

      # todo parse file list, in case just commiting some files
      # todo call revlog, commit files
      # todo call repos, update commit

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
