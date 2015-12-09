# Frank Tamburrino
# CSC 253
# PushPull Module
# November 6, 2015
#
# How to use for Push, Pull and Clone:
#   Push - cn push <user> <repo.host:/dir/of/repo> <branch-name>
#   Pull - cn pull <user> <repo.host:/dir/of/repo> <branch-name>
#   Clone - cn clone <user> <repo.host:/dir/of/repo>
# assumes that the user has ssh keys to the remote server setup

module Copernicium
  include Workspace
  module PushPull
    # Fields in UIComm and what they are for me:
    #   @opts - user
    #   @repo - repo.host:/path/to/repo
    #   @repo - :/path/to/repo
    #   @rev - branch name
    def PushPull.UICommandParser(comm)
      # handle parsing out remote info
      remote = comm.repo.split(':')
      if remote.length == 2
         @@host = remote[0]
         @@path = remote[1]
      elsif remote.length == 1
         @@host = "cycle3.csug.rochester.edu"
         @@path = remote[0].sub!(/^:/, '')
      else
        raise 'Remote host information not given'.red
      end

      @@user = comm.opts
      case comm.command
      when "clone"
        clone
      when "push"
        push
      when "pull"
        pull
      else
        raise "Error: Invalid command supplied to PushPull".red
      end
    end

    # execute commands on the server
    def execute(commands)
      Net::SSH.start(@@repo, @@user) do |ssh|
        commands.each do |command|
          puts ssh.exec!(command)
        end
      end
    end

    # tell user to set up their ssh keys
    def connection_failure(str = '')
      puts "Connection error while: ".red + str
      puts "Make sure ssh keys are setup.".yel
      return false
    end

    # Function: connect()
    #
    # Description:
    #   a net/ssh wrapper, if given a block will execute block on server,
    #   otherwise tests connection.
    #
    # remote: the remote server, formatted "my.server"
    # user: the user to connect as
    def PushPull.connect
      begin
        Net::SCP.start(@@host, @@user) { |scp| yield scp }
        true
      rescue
        connection_failure 'trying to execute a command'
      end
    end

    # Function: transfer()
    #
    # Description:
    #   a net/scp wrapper to copy to server
    #
    # remote: the remote server and directory to pull from, formatted "my.server"
    # user: the user to connect as
    def PushPull.transfer
      begin
        Net::SCP.start(remote, @@user) { |scp| yield scp }
        true
      rescue
        connection_failure 'trying to upload a file'
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
    def PushPull.fetch(local = Dir.pwd, &block)
      if block.nil? # we are cloning a repo in this section of code
        begin
          puts '<' + @@host + '>'
          puts '<' + @@user + '>'
          Net::SCP.start(@@host, @@user) do |scp|
            scp.download!(@@path, local, :recursive => true)
          end
          true
        rescue # no ssh keys are setup, die
          connection_failure 'trying to copy a file'
        end

      else # fetch more than one file or folder
        begin
          Net::SCP.start(@@host, @@user) { |scp| yield scp }
          true
        rescue
          connection_failure "trying to fetch files"
        end
      end
    end

    # Function: push()
    #
    # Description:
    #   pushes local changes on the current branch to a remote branch
    #
    # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
    # branch: the branch that we are pushing to
    # user: the user to connect as
    def PushPull.push
      transfer do |session|
        session.upload!("#{Dir.pwd}/.cn/revs", "#{dest[1]}/.cn/revs", :recursive => true)
        session.upload!("#{Dir.pwd}/.cn/snap", "#{dest[1]}/.cn/snap", :recursive => true)
        session.upload!("#{Dir.pwd}/.cn/history", "#{dest[1]}/.cn/merging_#{@@user}", :recursive => true)
      end

      connect do |session|
        session.exec!("cd #{dest[1]}")
        puts session.exec!("cn update #{@@user}")
      end
    end


    # Function: pull()
    #
    # Description:
    #   pulls remote changes to the current branch from remote branch
    #
    # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
    # branch: the branch that we are pushing to
    # user: the user to connect as
    def PushPull.pull
      fetch(dest[0], nil, nil, @@user) do |session|
        session.download!("#{dest[1]}/.cn/revs", "#{Dir.pwd}/.cn/revs", :recursive => true)
        session.download!("#{dest[1]}/.cn/snap", "#{Dir.pwd}/.cn/snap", :recursive => true)
        session.download!("#{dest[1]}/.cn/history", "#{Dir.pwd}/.cn/merging_#{@@user}", :recursive => true)
      end
      puts `cn update #{user}`
    end


    # Function: clone()
    #
    # Description:
    #   Grabs a repository from a remote server
    #
    # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
    # user: the user to connect as
    def PushPull.clone
      begin
        PushPull.fetch
      rescue
        connection_failure 'trying to clone a repo'
      end
    end
  end
end

