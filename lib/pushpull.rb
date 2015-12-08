# Frank Tamburrino
# CSC 253
# PushPull Module
# November 6, 2015
require_relative 'required'

module Copernicium
  # How to use for Push, Pull and Clone:
  #   Push - cn push <user> <repo.host:/dir/of/repo> <branch-name>
  #   Pull - cn pull <user> <repo.host:/dir/of/repo> <branch-name>
  #   Clone - cn clone <user> <repo.host:/dir/of/repo>
  include Workspace
  class UIComm
  end

  module PushPull
    # Chris's edit
    # Takes in Ethan's UICommandCommunicator object and calls
  # a method based on the command
    #
    # Fields in UIComm and what they are for me:
    #   @opts - user
    #   @repo - repo.host:/path/to/repo
    #   @rev - branch name
    def PushPull.UICommandParser(ui_comm)
      case ui_comm.command
      when "clone"
        clone(ui_comm.repo, ui_comm.opts.first)
      when "push"
        push(ui_comm.repo, ui_comm.rev, ui_comm.opts.first)
      when "pull"
        pull(ui_comm.repo, ui_comm.rev, ui_comm.opts.first)
      else
        raise "Error: Invalid command supplied to PushPull".red
      end
    end

    # Function: connect()
    #
    # Description:
    #   a net/ssh wrapper, if given a block will execute block on server,
    #   otherwise tests connection.
    #
    # remote: the remote server, formatted "my.server"
    # user: the user to connect as
    def PushPull.connect(remote, user, &block)
      exit_code = false
      puts 'inside PushPull connect'.blu
      if(block.nil?)
        begin
          puts 'inside PushPull connect nil block path'.grn
        Net::SSH.start(remote, user) do |ssh|
            puts ssh.exec!("echo Successful Connection!")
            exit_code = true
          end
        rescue
          begin
            print "Username for remote repo?: "
            user = (STDIN.readline).strip

            print "Password for #{user}: "
            passwd = (STDIN.noecho(&:gets)).strip
            puts

            Net::SSH.start(remote, user, :password => passwd) do |ssh|
              puts ssh.exec!("echo Successful Connection!")
              exit_code = true
            end
          rescue
            raise "Unsuccessful Connection".red
          end
        end
      else
        begin
          Net::SSH.start(remote, user) do |ssh|
            yield ssh
          end
          exit_code = true
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
            exit_code = true
          rescue
            raise "Unable to execute command!".red
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
    # remote: the remote server and directory to pull from, formatted "my.server"
    # user: the user to connect as
    def PushPull.transfer(remote, user, &block)
      begin
        Net::SCP.start(remote, user) do |scp|
          yield scp
        end
        return true
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
          return true
        rescue
          raise "Unable to upload file!".red
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
    def PushPull.fetch(remote, dest, local, user, &block)
      exit_code = false
      if(block.nil?)
        begin
          Net::SCP.start(remote, user) do |scp|
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
            raise "Unable to fetch file(s)!".red
          end
        end
      else
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

            Net::SCP.start(remote, user, :password => passwd) do |scp|
              yield scp
            end
            exit_code = true
          rescue
            raise "Unable to fetch file(s)!".red
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
    def PushPull.push(remote, branch, user)
      dest = remote.split(':')
      if(dest.length != 2)
        dest = dest.insert(0, "cycle3.csug.rochester.edu")
      end
      if(!Dir.exists?('.cn'))
      	puts 'failed to push to remote, not an initialized Copernicium repo'
      	return nil
      end
      transfer(dest[0], user) do |session|
      	session.upload!("#{Dir.pwd}/.cn/revs", "#{dest[1]}/.cn/revs", :recursive => true)
      	session.upload!("#{Dir.pwd}/.cn/snap", "#{dest[1]}/.cn/snap", :recursive => true)
      	session.upload!("#{Dir.pwd}/.cn/history", "#{dest[1]}/.cn/merging_#{user}", :recursive => true)
      end
      connect(dest[0], user) do |session|
      	session.exec!("cd #{dest[1]}")
      	result = session.exec!("cn update #{user}")
      end
      puts result
    end

    # Function: pull()
    #
    # Description:
    #   pulls remote changes to the current branch from remote branch
    #
    # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
    # branch: the branch that we are pushing to
    # user: the user to connect as
    def PushPull.pull(remote, branch, user)
      dest = remote.split(':')
      if(dest.length != 2)
        dest = dest.insert(0, "cycle3.csug.rochester.edu")
      end
      if(!Dir.exists?('.cn'))
      	puts 'failed to push to remote, not an initialized Copernicium repo'
      	return nil
      end
      fetch(dest[0], nil, nil, user) do |session|
      	session.download!("#{dest[1]}/.cn/revs", "#{Dir.pwd}/.cn/revs", :recursive => true)
      	session.download!("#{dest[1]}/.cn/snap", "#{Dir.pwd}/.cn/snap", :recursive => true)
      	session.download!("#{dest[1]}/.cn/history", "#{Dir.pwd}/.cn/merging_#{user}", :recursive => true)
  	  end
  	  system "cn update #{user}"
    end

    # Function: clone()
    #
    # Description:
    #   Grabs a repository from a remote server
    #
    # remote: the remote server and directory to push to, formatted "my.server:/the/location/we/want"
    # user: the user to connect as
    def PushPull.clone(remote, user = nil)
      exit_code = false
      dest = remote.split(':')
      if(dest.length != 2)
        dest = dest.insert(0, "cycle3.csug.rochester.edu")
      end
      begin
        fetch(dest[0], dest[1], Dir.pwd, user)
        exit_code = true
      rescue
        puts "Failed to clone the remote branch!".red
      end

      return exit_code
    end
  end
end

