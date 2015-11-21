# Frank Tamburrino
# CSC 253
# PushPull Module
# November 6, 2015
require 'socket'        # Socket needed for communicating over the network
require 'io/console'    # Needed to hide password at console
require 'net/ssh'       # Needed to communicate with the remote
require 'net/scp'       # Needed for file transfer between servers
require_relative 'repos' 
require_relative 'RevLog'
require_relative 'ui'

module Copernicium
  class PushPull

    def connect(remote, user = nil, passwd = nil, &block)
      exit_code = false
      if(block.nil?)
        begin
          if(user.nil?)
            print "Username for remote repo?: "
            user = (STDIN.readline).strip
          end
          if(passwd.nil?)
            print "Password for #{user}: "
            passwd = (STDIN.noecho(&:gets)).strip
            puts
          end
          Net::SSH.start(remote, user, :password => passwd) do |ssh|
            result = ssh.exec!("echo Successful Connection!")
            puts result
            exit_code = true;
          end
        rescue
          puts "Connection Unsuccessful"
        end
      else
        begin
          if(user.nil?)
            print "Username for remote repo: "
            user = (STDIN.readline).strip
          end
          if(passwd.nil?)
            print "Password for #{user}: "
            passwd = (STDIN.noecho(&:gets)).strip
            puts
          end
          Net::SSH.start(remote, user, :password => passwd) do |ssh|
            yield ssh
          end
          exit_code = true;
        rescue
          puts "Unable to execute command!"
        end
      end
      return exit_code
    end
    
    def transfer(remote, local, dest, user = nil, passwd = nil)
      exit_code = false
      if(user.nil?)
        print "Username for remote repo: "
        user = (STDIN.readline).strip
      end
      if(passwd.nil?)
        print "Password for #{user}: "
        passwd = (STDIN.noecho(&:gets)).strip
        puts
      end
      begin
        Net::SCP.start(remote, user, :password => passwd) do |scp|
          scp.upload!(local, dest)
        end
        exit_code = true
      rescue
        puts "Unable to upload file!"
      end
    end

    def fetch(remote, dest, local, user = nil, passwd = nil)
      exit_code = false
      if(user.nil?)
        print "Username for remote repo: "
        user = (STDIN.readline).strip
      end
      if(passwd.nil?)
        print "Password for #{user}: "
        passwd = (STDIN.noecho(&:gets)).strip
        puts
      end
      begin
        Net::SCP.start(remote, user, :password => passwd) do |scp|
          scp.download!(dest, local, :recursive => true)
        end
        exit_code = true
      rescue
        puts "Unable to fetch file(s)!"
      end

      return exit_code
    end

    def push(remote, branch, remote_dir)
      ################ One way we can handle it ###################
      ################ Needs Repos and Revlog Functionality! ######
      # snap_id = (Repos::Repo.history(branch)).last
      # snap = RevLog::RevLog.get_file(snap_id)
      # connect(remote) do |x|
      #   result = test.exec!("<call to Repos to diff the snapshots>")
      # end
      # print "Username for remote repo: "
      # user = (STDIN.readline).strip
      # print "Password for #{user}: "
      # passwd = (STDIN.noecho(&:gets)).strip
      # puts
      # for result.each do |x|
      #   transfer(remote, "./#{x}", remote_dir, user, passwd)
      # end
      # connect(remote) do |x|
      #   test.exec!("<call to Repos to merge the files>")
      #   test.exec!("<clean up the files>")
      # end
      #############################################################
    end

    def pull(remote, branch, remote_dir)
      ################ One way we can handle it ###################
      ################ Needs Repos and Revlog Functionality! ######
      # snap_id = (Repos::Repo.history(branch)).last
      # snap = RevLog::RevLog.get_file(snap_id)
      # connect(remote) do |x|
      #   result = test.exec!("<call to Repos to diff the snapshots>")
      # end
      # print "Username for remote repo: "
      # user = (STDIN.readline).strip
      # print "Password for #{user}: "
      # passwd = (STDIN.noecho(&:gets)).strip
      # puts
      # for result.each do |x|
      #   fetch(remote, remote_dir, "./#{x}", user, passwd)
      #   RevLog::Revlog.merge(x, local_x)
      #   File.delete(x)
      # end
      #############################################################
    end

    def clone(remote, dir, user = nil, passwd = nil)
      exit_code = false
      if(user.nil?)
        print "Username for remote repo: "
        user = (STDIN.readline).strip
      end
      if(passwd.nil?)
        print "Password for #{user}: "
        passwd = (STDIN.noecho(&:gets)).strip
        puts
      end
      begin
        fetch(remote, dir, ".", user, passwd)
        nd = File.basename(dir)
        ################ Needs Repos Functionality! #################
        # Initializes the folder as a Repo
        # Repos::Repos.make_branch(nd)
        #############################################################
        exit_code = true;
      rescue
        puts "Failed to clone the remote branch!"
      end

      return exit_code
    end

  end
end