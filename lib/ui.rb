# user interface module - parse and execute commands
# integrates all modules, central module

VERSION = "0.0.2"

module Copernicium
  # Communication object that will pass commands to backend modules
  # also used in unit test to make sure command is being parsed ok
  # rev - revision indicator (commit #, branch name, HEAD, etc.)
  # repo - URL/path to a remote repository
  class UIComm
    attr_reader :command, :files, :rev, :cmt_msg, :repo, :opts
    def initialize(command: nil, files: nil, rev: nil,
                   cmt_msg: nil, repo: nil, opts: nil)
      @cmt_msg = cmt_msg
      @command = command
      @files = files
      @opts = opts
      @repo = repo
      @rev = rev
    end
  end

  # main driver for the command line user interface
  class Driver
    include Workspace
    include Repos
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

      # if -v flag givem show version
      pexit VERSION, 0 if cmd == '-v'

      # if no arguments given show help information
      pexit COMMAND_BANNER, 0 if (cmd == '-h' || cmd == 'help')

      # if not in a repo, warn them, tell how to create
      puts REPO_WARNING.yel if (noroot? && cmd != 'init')

      # Handle standard commands
      case cmd
      when 'init'
        init args
      when 'status'
        status args
      when 'history'
        history args
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

    # Print and exit with a specific code
    def pexit(msg, sig)
      puts msg
      exit sig
    end

    # Get some info from the user when they dont specify it
    def get(info)
      puts "Note: #{info} not specified. Enter #{info} to continue."
      gets.chomp # read a line from user, and return it
    end

    # create a new copernicium repository
    def init(args)
      Workspace.setup
      if args.nil?
        Workspace.create_project
      else # init into a folder
        Workspace.create_project
      end
      puts "Created Copernicium repo in " + Dir.pwd.grn
      UIComm.new(command: 'init', opts: args)
    end

    # show the current repos status
    def status(args)
      ui = UIComm.new(command: 'status', opts: args)
      st = Workspace.status(ui)
      st[0].each { |f| puts "Added:\t".grn + f }
      st[1].each { |f| puts "Edited:\t".yel + f }
      st[2].each { |f| puts "Removed:\t".red + f }
      ui
    end

    # check whether a specific branch exists
    def isbranch?(branch)
      Repos.branches.include? branch
    end

    # create and switch to a new branch
    def create_branch(branch)
      new_branch_hash = Repos.make_branch branch
      Repos.update_branch branch
      puts "Created new branch '#{branch}' with head #{new_branch_hash}".grn
    end

    def branch(args)
      branch = args.first
      if branch.nil? # show all branches
        puts "Branches: ".grn + branches.join(' ')
      elsif branch == '-c' # try to create a new branch
        # If branch name not specified, get it from the user
        branch = args[1]
        branch = get "new branch name" if branch.nil?

        # Create and switch to the new branch
        create_branch branch
      elsif branch == '-r' # rename the current branch
        # If branch name not specified, get it from the user
        newname = args[1]
        newname = get "new name for current branch" if newname.nil?

        oldname = Repos.branch

        # Create and switch to a new branch with the given name
        create_branch newname
        # Delete the branch with the old name
        Repos.delete_branch oldname
        puts "Deleted branch '#{oldname}'"

        puts "Renamed branch '#{oldname}' to '#{newname}'".grn
      elsif isbranch? branch # switch branch
        Repos.update_branch  branch
      else # branch does not exist, create it, switch to it
        create_branch branch
      end
    end

    def push(args)
      UIComm.new(command: 'push', opts: args)
      # todo - make call to pushpull, push remote
    end

    def pull(args)
      UIComm.new(command: 'pull', opts: args)
      #def pull(remote, branch', remote_dir)
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
      Workspace.checkout(ui)
      ui
    end

    def clean(args = [])
      ui = UIComm.new(command: 'clean', files: args)
      Workspace.clean(ui)
      ui
    end

    def clone(args)
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
      elsif messflag == 0 # commit everything
        # mash everything after -m into a string
        message = args[1..-1].join ' '
      else # commit only some files
        files = args[0..messflag - 1]
      end

      # specified the -m flag, but didnt give anything
      message = get 'commit message' if message.nil?

      # perform the commit, with workspace
      ui = UIComm.new(command: 'commit', files: files, cmt_msg: message)
      Workspace.commit(ui)
      ui
    end

    def history(args)
    end

    def merge(args)
      if args.empty?
        puts 'I need a commit or branch to merge.'
        rev = get 'single commit or branch to merge'
      else # use given
        rev = args.first
        # get all branchs, see if arg is in it.
        # if so, look up snapshot of <branch> head
        # TODO - parse whether given arg is a branch name, else assume snap id
        # todo - call repos merge command
        # todo show conflicting files
        UIComm.new(command: 'merge', rev: rev)
      end
    end
  end # Driver
end

