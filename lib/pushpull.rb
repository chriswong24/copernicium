# Frank Tamburrino
# CSC 253
# PushPull Module
# November 6, 2015
require 'net/ssh'
require 'net/scp'


module PushPull
  # How to use for Push, Pull and Clone:
  #   Push - cn push <user> <repo.host:/dir/of/repo> <branch-name>
  #   Pull - cn pull <user> <repo.host:/dir/of/repo> <branch-name>
  #   Clone - cn clone <user> <repo.host:/dir/of/repo>
  class UIComm
    attr_reader :command, :files, :rev, :cmt_msg, :repo, :opts
      def initialize(command: nil, files: nil, rev: nil, cmt_msg: nil, repo: nil, opts: nil)
      @cmt_msg = cmt_msg
      @command = command
      @files = files
      @opts = opts
      @repo = repo
      @rev = rev
    end
  end

  # Chris's edit
  # Takes in Ethan's UICommandCommunicator object and calls
  # a method based on the command
  #
  # Fields in UIComm and what they are for me:
  #   @opts - user
  #   @repo - repo.host:/path/to/repo
  #   @rev - branch name
  def self.UICommandParser(ui_comm)
    case ui_comm.command
    when "clone"
      clone(ui_comm.repo, ui_comm.opts)
    when "push"
      push(ui_comm.repo, ui_comm.rev, ui_comm.opts)
    when "pull"
      pull(ui_comm.repo, ui_comm.rev, ui_comm.opts)
    else
      print "Error: Invalid command supplied to PushPull!" # Bad error handling, will fix later
      return nil
    end
  end

  # Function: connect()
  #
  # Description:
  #   a net/ssh wrapper, if given a block will execute block on server, otherwise tests connection.
  #
  # remote: the remote server, formatted "my.server"
  # user: the user to connect as
  def self.connect(remote, user, &block)
    exit_code = false
    if(block.nil?)
      begin
        Net::SSH.start(remote, user) do |ssh|
          result = ssh.exec!("echo Successful Connection!")
          puts result
          exit_code = true;
        end
      rescue
        begin
          print "Username for remote repo?: "
          user = (STDIN.readline).strip

          print "Password for #{user}: "
          passwd = (STDIN.noecho(&:gets)).strip
          puts

          Net::SSH.start(remote, user, :password => passwd) do |ssh|
            result = ssh.exec!("echo Successful Connection!")
            puts result
            exit_code = true;
          end
        rescue
            puts "Unsuccessful Connection"
        end
      end
    else
      begin
        Net::SSH.start(remote, user) do |ssh|
          yield ssh
        end
        exit_code = true;
      rescue
        begin
          print "Username for remote repo: "
          user = (STDIN.readline).strip

          print "Password for #{user}: "
          passwd = (STDIN.noecho(&:gets)).strip
          puts

          Net::SSH.start(remote, user, :password => passwd) do |ssh|
            yield ssh
          end
          exit_code = true;
        rescue
          puts "Unable to execute command!"
        end
      end
    end
    return exit_code
  end

  # Function: transfer()
  #
  # Description:
  #   a net/scp wrapper to copy to server
  #
  # remote: the remote server and directory to pull from, formatted "my.server:/the/location/we/want"
  # user: the user to connect as
  def self.transfer(remote, user, &block)
    exit_code = false
    begin
      Net::SCP.start(remote, user) do |scp|
        yield scp
      end
      exit_code = true
    rescue
      begin
        print "Username for remote repo: "
        user = (STDIN.readline).strip

        print "Password for #{user}: "
        passwd = (STDIN.noecho(&:gets)).strip
        puts

        Net::SCP.start(remote, user, :passwd => passwd) do |scp|
          yield scp
        end
        exit_code = true
      rescue
        puts "Unable to upload file!"
      end
    end
  end

  # Function: fetch()
  #
  # Description:
  #   a net/scp wrapper to copy from server, can take a block or do a one-off copy without one
  #
  # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
  # dest: what we want of the branch, not needed for blocked calls
  # local: where we want to put the file, not needed for blocked calls
  # user: the user to connect as
  def self.fetch(remote, dest, local, user, &block)
    exit_code = false
    if(block.nil?)
      begin
        Net::SCP.start(remote, user, :password => passwd) do |scp|
          scp.download!(dest, local, :recursive => true)
        end
        exit_code = true
      rescue
        begin
          print "Username for remote repo: "
          user = (STDIN.readline).strip

          print "Password for #{user}: "
          passwd = (STDIN.noecho(&:gets)).strip
          puts

          Net::SCP.start(remote, user, :password => passwd) do |scp|
            scp.download!(dest, local, :recursive => true)
          end
          exit_code = true
        rescue
          puts "Unable to fetch file(s)!"
        end
      end
    else
      begin
        Net::SCP.start(remote, user, :password => passwd) do |scp|
          yield scp
        end
        exit_code = true
      rescue
        begin
          print "Username for remote repo: "
          user = (STDIN.readline).strip

          print "Password for #{user}: "
          passwd = (STDIN.noecho(&:gets)).strip
          puts

          Net::SCP.start(remote, user, :password => passwd) do |scp|
            yield scp
          end
          exit_code = true
        rescue
          puts "Unable to fetch file(s)!"
        end
      end
    end
    return exit_code
  end

  # Function: push()
  #
  # Description:
  #   pushes local changes on the current branch to a remote branch
  #
  # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
  # branch: the branch that we are pushing to
  # user: the user to connect as
  def self.push(remote, branch, user)
    # check contents of folder for .cn, fail if not present and remove otherwise
    dest = remote.split(':');
    contents = Dir.entries(Dir.pwd)
    if(!content.include? '.cn')
      puts 'failed to push to remote, not an initialized Copernicium repo'
      return
    else
      contents = contents.delete_if{|x| (x.eql? '.cn') || (x.eql? '.') || (x.eql? '..')}
    end

    # todo - check if branch exists on the remote server
    # if so, dump contents and save a new commit saying pushed from user
    # else, create branch and dump files, then make a new commit saying
    # created branch
    connect(dest[0], user) do |session|
      session.exec!("cd #{dest[1]}")
      result = session.exec!('ls .cn')
      if(result.strip.eql? '')
        puts 'remote directory not a Copernicium repo'
        return
      end
      session.exec!("cn branch .temp_push_#{user}")
      session.exec!("find . ! -name \".cn\" -exec rm -r {} \\;")

      # Move the files over to the remote branch
      transfer(dest[0], user) do |scp|
        contents.each do |x|
          scp.upload!(Dir.pwd+'/'+x, dest[1], :recursive => true)
        end
      end

      # Commit the files and merge the branches
      session.exec!('cn add .')
      session.exec!('cn commit -m \'Temp commit for push\'')
      session.exec!("cn checkout #{branch}")
      session.exec!("cn merge .temp_push_#{user}")
      session.exec!("cn branch -r temp_push_#{user}")
    end

    puts "Successfully pushed to #{remote}"
  end

  # Function: pull()
  #
  # Description:
  #   pulls remote changes to the current branch from remote branch
  #
  # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
  # branch: the branch that we are pushing to
  # user: the user to connect as
  def self.pull(remote, branch, user)
    # check contents of folder for .cn, fail if not present and remove otherwise
    crbr = Repos.new.current_branch() # assumed function
    dest = remote.split(':');
    contents = Dir.entries(Dir.pwd)
    if(!content.include? '.cn')
      puts 'failed to pull from remote, not an initialized Copernicium repo'
      return
    else
      contents = contents.delete_if{|x| (x.eql? '.cn') || (x.eql? '.') || (x.eql? '..')}
    end

    # create a new branch and clean it in prep for the incoming files
    system "cn branch .temp_pull_#{user}"
    contents.each do |x|
      system "rm -r #{x}"
    end

    # get the file list from the remote directory
    connect(dest[0], user) do |session|
      session.exec!("cd #{dest[1]}")
      session.exec!("cn checkout #{branch}")
      collection = session.exec!("ls | cat")
    end
    collection  = collection.split('\n')
    if(!collection.include? '.cn')
      puts 'failed to pull from remote, remote folder not an initialized Copernicium repo'
      return
    else
      collection = collection.delete_if{|x| (x.eql? '.cn') || (x.eql? '.') || (x.eql? '..')}
    end

    # fetch the files from the remote directory and merge them to the branch
    fetch(dest[0], nil, nil, user) do |scp|
      collection.each do |x|
        scp.download!(dest[1]+'/'+x, Dir.pwd, :recursive => true)
      end
    end
    system "cn add ."
    system "cn commit -m \'Temp commit for pull\'"
    system "cn checkout #{crbr}"
    system "cn merge .temp_pull_#{user}"
    system "cn branch -r .temp_pull_#{user}"
    puts "Successfully pulled from #{remote}"
  end

  # Function: clone()
  #
  # Description:
  #   Grabs a repository from a remote server
  #
  # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
  # user: the user to connect as
  def self.clone(remote, user = nil)
    exit_code = false
    dest = remote.split(':')
    begin
      fetch(dest[0], dest[1], Dir.pwd, user)
      exit_code = true;
    rescue
      puts "Failed to clone the remote branch!"
    end

    return exit_code
  end
end
