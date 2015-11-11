# Frank Tamburrino
# CSC 253
# PushPull Module
# November 6, 2015
require 'socket'        # Socket needed for communicating over the network
require 'io/console'    # Needed to hide password at console
require 'net/ssh'       # Needed to communicate with the remote
require 'net/scp'       # Needed for file transfer between servers

module Copernicium_PushPull
  class PushPull

    def connect(remote, &block)
      exit_code = false
      if(block.nil?)
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
          puts "Connection Unsuccessful"
        end
      else
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

    def push(placeholder)
    end

    def pull(placeholder)
    end

    def clone(placeholder)
    end

  end
end
