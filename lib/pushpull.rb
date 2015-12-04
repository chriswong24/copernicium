# Frank Tamburrino
# CSC 253
# PushPull Module
# November 6, 2015
require 'net/ssh'
require 'net/scp'


module Copernicium
  class PushPull

    # Chris's edit
    # Takes in Ethan's UICommandCommunicator object and calls
    # a method based on the command
    def UICommandParser(ui_comm)
      case ui_comm.command
      when "clone"
        #clone()
      when "merge"
        # do merge stuff
      when "push"
        #push(ui_comm.)
      when "pull"
        #pull(ui_comm.branchname,)
      else
        print "Error: Invalid command supplied to PushPull!" # Bad error handling, will fix later
        return nil
      end
    end

    def connect(remote, user = nil, passwd = nil, &block)
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
      end
      return exit_code
    end

    def transfer(remote, local, dest, user = nil, passwd = nil)
      exit_code = false
      begin
        Net::SCP.start(remote, user) do |scp|
          scp.upload!(local, dest)
        end
        exit_code = true
      rescue
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

          Net::SCP.start(remote, user, :passwd => passwd) do |scp|
            scp.upload!(local, dest)
          end
          exit_code = true
        rescue
          puts "Unable to upload file!"
        end
      end
    end

    def fetch(remote, dest, local, user = nil, passwd = nil)
      exit_code = false
      begin
        Net::SCP.start(remote, user, :password => passwd) do |scp|
          scp.download!(dest, local, :recursive => true)
        end
        exit_code = true
      rescue
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

          Net::SCP.start(remote, user, :password => passwd) do |scp|
            scp.download!(dest, local, :recursive => true)
          end
          exit_code = true
        rescue
          puts "Unable to fetch file(s)!"
        end
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
      begin
        fetch(remote, dir, ".", user, passwd)
        nd = File.basename(dir)
        # Initializes the folder as a Repo
        Repos::Repos.make_branch(nd)
        exit_code = true;
      rescue
        puts "Failed to clone the remote branch!"
      end

      return exit_code
    end

  end
end
