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
        @@host = remote[0].strip
        @@path = remote[1].strip
      elsif remote.length == 1
        @@host = "cycle3.csug.rochester.edu"
        @@path = remote.first.strip
      else
        raise 'Remote host information not given.'.red
      end

      @@user = comm.opts
      case comm.command
      when "clone"
        clone
      when "push"
        push
      when "pull"
        pull
      when 'test'
        # avoid error while doing unit testing
      else
        raise "Error: Invalid command supplied to PushPull".red
      end
    end

    # tell user to set up their ssh keys
    def PushPull.connection_failure(str = '')
      puts "Connection error while: ".red + str
      puts "Make sure SSH keys are setup.".yel
      puts "User: ".yel + @@user
      puts "Host: ".yel + @@host
      puts "Path: ".yel + @@path
      false
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
        Net::SSH.start(@@host, @@user) { |scp| yield scp }
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
        Net::SCP.start(@@host, @@user) { |scp| yield scp }
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
          Net::SCP.start(@@host, @@user) do |scp|
            scp.download! @@path, local, :recursive => true
          end
        rescue # no ssh keys are setup, die
          connection_failure 'trying to copy a file'
        end

      else # fetch more than one file or folder
        begin
          Net::SCP.start(@@host, @@user) { |scp| yield scp }
        rescue
          connection_failure "trying to fetch files"
        end
      end
      true
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
      begin
        transfer do |ssh|
          # uploading our history to remote
          ssh.upload!("#{Dir.pwd}/.cn/history",
                      "#{@@path}/.cn/merging_#{@@user}")

          # uploading our .cn info to remote
          %w{revs snap}.each do |file|
            ssh.upload!("#{Dir.pwd}/.cn/#{file}/",
                        "#{@@path}/.cn/#{file}/",
                        :recursive => true)
          end
        end # ssh

        connect do |ssh|
          ssh.exec! "cd #{@@path}"
          puts ssh.exec! "cn update #{@@user}"
        end
      rescue
        connection_failure "trying to push files"
      end
      true
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
      begin
        fetch do |session|
          # uploading our history to remote
          session.download!("#{@@path}/.cn/merging_#{@@user}",
                            "#{Dir.pwd}/.cn/history")

          # uploading our .cn info to remote
          %w{revs snap}.each do |file|
            session.download!("#{@@path}/.cn/#{file}",
                              "#{Dir.pwd}/.cn/#{file}",
                              :recursive => true)
          end
        end
        system "cn update", @@user
        puts "Remote pulled: ".grn + @@host + @@path
      rescue
        connection_failure "trying to pull files"
      end
      true
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

