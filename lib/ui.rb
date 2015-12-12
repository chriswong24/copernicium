# user interface module - parse and execute commands
# integrates all modules, central module

VERSION = "0.2.3"

include Copernicium::PushPull

module Copernicium
  # Communication object that will pass commands to backend modules
  # also used in unit test to make sure command is being parsed ok
  # rev - revision indicator (commit #, branch name, HEAD, etc.)
  # repo - URL/path to a remote repository
  class UIComm
    attr_accessor :command, :files, :rev, :cmt_msg, :repo, :opts
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
  module Driver
    include Workspace # needed for most high level commands
    include PushPull # needed for most high level commands
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

      # create the cn project, else already in one
      if cmd == 'init'
        noroot?? init(args) : puts(IN_REPO_WARNING.yel, getroot)
      elsif cmd == 'clone' # allow cloning a new repo
          clonecn args
      elsif noroot? # if not in a repo, warn them, tell how to create
        puts NO_REPO_WARNING.yel
      else # now, assume we are in a copernicum project
        Workspace.setup

        # Handle all other commands
        case cmd
        when 'status'
          status args
        when 'history'
          history args
        when 'branch'
          branch args
        when 'clean'
          clean args
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
        when 'update'
          update args
        when 'init'
          # fall through - init handled above, before case statement
        else # handle an unrecognized argument, show help and exit
          pexit "Unrecognized command #{cmd}\n" + COMMAND_BANNER, 1
        end
      end # case
    end # run

    # Print and exit with a specific code
    def pexit(msg, sig)
      puts msg
      exit sig
    end

    # Get some info from the user when they dont specify it
    def get(info)
      puts "Note: #{info} not specified. Enter #{info} to continue.".yel
      gets.chomp # read a line from user, and return it
    end

    # create a new copernicium repository
    def init(args)
      if args.empty?
        root = Workspace.create_project
      else # init into a folder
        root = Workspace.create_project args.first
      end
      puts "Created Copernicium repo: ".grn + root
      UIComm.new(command: 'init', opts: args)
    end

    # show the current repos status
    def status(args)
      st = Workspace.status
      if st.all?(&:empty?)
        puts "No changes since last commit | ".grn +
          (Repos.current_snaps.last.time + ' | ').yel +
          Repos.current_snaps.last.msg
      else
        st[0].each { |f| puts "Added:   ".grn + f }
        st[1].each { |f| puts "Edited:  ".yel + f }
        st[2].each { |f| puts "Removed: ".red + f }
      end
    end

    # create and switch to a new branch
    def create_branch(branch)
      new_branch_hash = Repos.make_branch branch
      Repos.update_branch branch
      puts "Created branch #{branch} ".grn + " with head #{new_branch_hash}"
    end

    def branch(args)
      branch = args.shift
      if branch.nil? # show all branches
        puts "Current: ".grn + Repos.current
        Repos.branches.each { |br| puts 'Branch: ' + br }
        puts "Total: ".grn + Repos.branches.length.to_s

      elsif branch == '-c' # create a new branch
        branch = args.first # get from the user
        branch = get "new branch name" if branch.nil?
        create_branch branch

      elsif branch == '-r' # rename branch
        newname = args.first # get if not specified
        newname = get "new name for current branch" if newname.nil?
        oldname = Repos.current
        create_branch newname
        Repos.delete_branch oldname
        puts "Deleted branch '#{oldname}'".grn
        puts "Renamed branch '#{oldname}' to '#{newname}'".grn

      elsif branch == '-d' # delete branch
        branch = args.first # If not specified, get
        branch = get "branch to delete" if branch.nil?
        if branch == Repos.current
          puts "Cannot delete the current branch!".red
        else # Delete the specified branch
          Repos.delete_branch branch
          puts "Deleted branch '#{branch}'".grn
        end

      elsif Repos.has_branch? branch # switch branch (branch <branch name>)
        Repos.update_branch branch
        puts 'Current: '.grn + Repos.current
        Workspace.checkout

      else # create it, switch to it
        Repos.create_branch branch
        Repos.update_branch branch
        Workspace.checkout
      end
    end

    def clonecn(args)
      user = args.first
      host = args.last
      user = get 'username for push' if user.nil?
      host = get 'host path (<host:/dir/of/repo>)' if host.nil? || user == host
      comm = UIComm.new(command: 'clone', repo: host, opts: user)
      PushPull.UICommandParser(comm)
      return comm
    end

    def push(args)
      user = args.first
      host = args.last
      user = get 'username for push' if user.nil?
      host = get 'host path (<host:/dir/of/repo>)' if host.nil? || user == host
      comm = UIComm.new(command: 'push', repo: host, opts: user)
      PushPull.UICommandParser(comm)
      return comm
    end

    def pull(args)
      user = args.first
      host = args.last
      user = get 'username for push' if user.nil?
      host = get 'host path (<host:/dir/of/repo>)' if host.nil? || user == host
      comm = UIComm.new(command: 'pull', repo: host, opts: user)
      PushPull.UICommandParser(comm)
      return comm
    end

    # Take in a revision (snaptshot) id or branch
    # Doesnt support file checkouts at this time
    def checkout(args)
      if args.empty?
        rev = get 'branch or commit id'
      else
        rev = args.shift
        files = args unless args.empty?
      end

      # if 'head' keyword, grab the head
      if rev == 'head'
        rev = Repos.current_head
      elsif Repos.has_branch? rev
        branch = rev
        rev = Repos.history(rev).last
      end

      # call workspace checkout the given / branch
      Workspace.checkout(UIComm.new(rev: rev, files: files))
      Repos.update_branch branch unless branch.nil?
    end

    def clean(args = [])
      ui = UIComm.new(command: 'clean', files: args)
      Workspace.clean(ui)
      ui
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
      puts 'New commit: '.grn + Workspace.commit(ui)
      ui
    end

    def history(args)
      Repos.current_snaps.reverse_each do |snap|
        puts (snap.time + ' | ') .grn + (snap.id + ' | ').yel + snap.msg
      end
    end

    def merge(args)
      if args.empty?
        rev = get 'branch to merge'
      else
        rev = args.first
      end

      # If rev is a branch name, resolve it to a rev ID.
      if Repos.has_branch? rev
        rev = (Repos.history rev).last
        conflicts = Workspace.merge(rev)
        unless conflicts.nil?
          conflicts.each { |conflict| puts 'Conflict: '.red + conflict }
        end
      else # branch not found
        puts 'Branch not found: '.red + rev
      end
    end

    def update(args)
      if args.empty?
        username = get 'user to update to'
      else
        username = args.first
      end
      Repos.update(UIComm.new(command: 'update', opts: username))
    end
  end # Driver
end # Copernicium

