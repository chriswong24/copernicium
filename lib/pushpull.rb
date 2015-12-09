# Frank Tamburrino
# CSC 254
# PushPull Module
# November 7, 2015
#
# How to use for Push, Pull and Clone:
#   Push - cn push <user> <repo.host:/dir/of/repo> <branch-name>
#   Pull - cn pull <user> <repo.host:/dir/of/repo> <branch-name>
#   Clone - cn clone <user> <repo.host:/dir/of/repo>
# assumes that the user has ssh keys to the remote server setup


module Copernicium
  module PushPull
    def PushPull.UICommandParser(comm)
      # handle parsing out remote info
      #   @opts - user
      #   @repo - repo.host:/path/to/repo
      #        OR /path/to/repo
      remote = comm.repo.split(':')
      if remote.length == 2
        @@host = remote[0]
        @@path = remote[1]
      elsif remote.length == 1
        @@host = "cycle3.csug.rochester.edu"
        @@path = remote.first
      else
        raise 'Remote host information not given.'.red
      end

      @@user = comm.opts
      case comm.command
      when "clone"
        PushPull.pclone
      when "push"
        PushPull.ppush
      when "pull"
        PushPull.ppull
      when 'test'
        # avoid error while doing unit testing
      else
        raise "Error: Invalid command supplied to PushPull".red
      end
    end

    # tell user to set up their ssh keys
    def PushPull.connection_failure(str = '', err = '')
      puts "Make sure SSH keys are setup to the host server.".grn
      puts "Connection error while: ".red + str
      puts "Error: ".red + err.to_s
      puts "Backtrace:\n\t".red + "#{err.backtrace.join("\n\t")}"
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
    def PushPull.connect
      begin
        Net::SSH.start(@@host, @@user) { |ssh| yield ssh }
        true
      rescue => error
        connection_failure 'trying to execute a command', error
      end
    end


    # Function: clone()
    #
    # Description:
    #   Grabs a repository from a remote server
    def PushPull.pclone
      begin
        PushPull.fetch
      rescue => error
        connection_failure 'trying to clone a repo', error
      end
    end


    # Function: transfer()
    #
    # Description:
    #   a net/scp wrapper to copy to server
    def PushPull.transfer
      begin
        Net::SCP.start(@@host, @@user) { |scp| yield scp }
        true
      rescue => error
        connection_failure 'trying to upload a file', error
      end
    end


    # Function: fetch()
    #
    # Description:
    #   a net/scp wrapper to copy from server, can take a block or do a one-off copy without one
    #
    # local: where we want to put the file, not needed for blocked calls
    def PushPull.fetch
      if block_given? # fetch more than one file or folder
        begin
          Net::SCP.start(@@host, @@user) { |scp| yield scp }
        rescue => error
          connection_failure "trying to fetch files", error
        end

      else # no block given, clone the repo
        begin
          Net::SCP.start(@@host, @@user) do |scp|
            scp.download!(@@path, Dir.pwd, :recursive => true)
          end
        rescue => error
          connection_failure 'trying to clone a repo', error
        end
      end
      true
    end


    # Function: ppush()
    #
    # Description:
    #   pushes local changes on the current branch to a remote branch
    def PushPull.ppush
      begin
        PushPull.transfer do |ssh|
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

        PushPull.connect do |ssh|
          puts ssh.exec! "cd #{@@path} && cn update #{@@user}"
        end
      rescue => error
        connection_failure "trying to push files", error
      end
      true
    end


    # Function: ppull()
    #
    # Description:
    #   pulls remote changes to the current branch from remote branch
    #
    def PushPull.ppull
      begin
        PushPull.fetch do |session|
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
      rescue => error
        connection_failure "trying to pull files", error
      end
      true
    end
  end
end

