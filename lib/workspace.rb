# This is the workspace module
# The functions are clean, commit, checkout and status

require 'singleton'
require 'pathname'
require_relative 'RevLog'
require_relative 'repos'

module Workspace
  class FileObj
    def initialize(path, ids)
      @path = path
      @history_hash_ids = ids
    end
    def path
      @path
    end
    def history_hash_ids
      @history_hash_ids
    end
  end
  class Workspace
    def self.writeFile(path, content)
      f = open(path, 'w')
      f.write(content)
      f.close
    end
    #private_class_method: writeFile

    def initialize
      @files = []
      @branch_name = ''
    end

    # if list_files is nil, then rollback the list of files from the branch
    # or rollback to the entire branch head pointed
    def clean(list_files)
      if list_files == nil
        # reset first: delete them from disk and reset @files
        @files.each{|x| File.delete(x.path)}
        @files = []
        # and then restore it with checkout()
        # if we have had a branch name
        if @branch_name != ''
          return checkout(@branch_name)
        # or it is the initial state, no commit and no checkout
        else
          return 0
        end
      else
        # check that every file need to be reset should have been recognized by the workspace
        list_files.each do |x|
          if x not in @files
            return -1
          end
        end
        # the actual action, delete all of them from the workspace first
        list_files.each{ |x| @files.delete(x)}
        # if we have had a branch, first we get the latest snapshot of it
        # and then checkout with the restored version of them
        if @branch_name != ''
          snapshot_id = repos.history(@branch_name)[-1]
          list_files = repos.restore_file(snapshot_id, list_files)
          return checkout(list_files)
        end
      end
    end

    # commit a list of files or the entire workspace to make a new snapshot
    def commit(list_files)
      if list_files != nil
        #files = []
        #list_files.each do |x|
        #  files.push(x)
        #end
        #snapshot = repos.last_snapshot
        #snapshot.files do |fff|
        #  if not files.in?(fff)
        #    files.push(fff)
        #  end
        #end
        return repos.make_snapshot(list_files)
      else
        return repos.make_snapshot(@files)
      end
    end

    def checkout(argu)
      # if argu is an Array Object, we assume it is a list of files to be added to the workspace
      if argu.is_a?(Array)
        # we add the list of files to @files regardless whether it has been in it.
        # that means there may be multiple versions of a file.
        argu.each do |x|
          @files.push(x)
          #path = x.path
          #hash = x.hash
          #content = RevLog.get_file(hash)
          #Workspace.writeFile(path,content)
        end
      # if argu is not an Array, we assume it is a String, representing the branch name
      # we first get the last snapshot id of the branch, and then get the commit object
      # and finally push all files of it to the workspace
      else
        snapshot_id = repos.history(argu)[-1]
        comm = repos.restore_snapshot(snapshot_id)
        comm.files do |fff|
          @files.push(fff)
          #path = fff.path
          #hash = fff.hash
          #content = RevLog.get_file(hash)
          #Workspace.writeFile(path,content)
        end
      end
    end

    def status()
      adds = []
      deletes = []
      edits = []
      if @branch_name != ''
        snapshot_id = repos.history(@branch_name)[-1]
        comm = repos.restore_snapshot(snapshot_id)
        comm.files do |x|
          idx = @files.index(x)
          if idx != nil
            diff = RevLog.diff_files(@files[idx].hash, x.hash)
            if diff.length == 0
              edits.push(x)
            end
          else
            deletes.push(x)
          end
        end
        @files do |x|
          if comm.files.index(x) == nil
            adds.push(x)
          end
        end
      end
      adds, edits, deletes
  end
end

