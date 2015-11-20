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
    def ==(rhs)
      if rhs.is_a? String
        @path == rhs
      else
        @path == rhs.path
      end
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
    def self.readFile(path)
      f = open(path, 'r')
      txt = f.read
      f.close
      txt
    end
    #private_class_method: writeFile
    #private_class_method: readFile

    def initialize
      @files = []
      @branch_name = ''
    end

    # if include all the elements in list_files
    def include?(list_files)
      list_files.each do |x|
        if @files.include? x == false
          return false
        end
      end
      true
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
          ###return 0
          return checkout(@branch_name)
        # or it is the initial state, no commit and no checkout
        else
          return 0
        end
      else
        # check that every file need to be reset should have been recognized by the workspace
        #workspace_files_paths = @files.each{|x| x.path}
        if self.include? list_files == false
          return -1
        end
        # the actual action, delete all of them from the workspace first
        list_files.each{|x| File.delete(x)}
        list_files.each{|x| @files.delete(x)}
        # if we have had a branch, first we get the latest snapshot of it
        # and then checkout with the restored version of them
        if @branch_name != ''
          return checkout(list_files)
        end
      end
    end

    # commit a list of files or the entire workspace to make a new snapshot
    def commit(list_files)
      if list_files != nil
        list_files.each do |x|
          if @files.include? x == false
            content = Workspace.read(x)
            hash = Revlop.add_file(x, content)
            fobj = FileObj.new(x, [hash,])
            @files.add(fobj)
          else
            content = Workspace.read(x)
            hash = Revlop.add_file(x, content)
            fobj = @files[@files.index(x)]
            if fobj.history_hash_ids[-1] != hash
              fobj.history_hash_ids << hash
            end
          end
        end
      end
      return repos.make_snapshot(@files)
    end

    def checkout(argu)
      # if argu is an Array Object, we assume it is a list of files to be added to the workspace
      if argu.is_a?(Array)
        # we add the list of files to @files regardless whether it has been in it.
        # that means there may be multiple versions of a file.
        list_files = argu
        list_files_last_commit = repos.get_snapshot(snapshot_id)
        list_files_last_commit.each do |x|
          if list_files.include? x.path
            path = x.path
            content = Revlog.get_file(x.history_hash_ids[-1])
            @files.push(x)
            Workspace.writeFile(path,content)
          end
        end
      # if argu is not an Array, we assume it is a String, representing the branch name
      # we first get the last snapshot id of the branch, and then get the commit object
      # and finally push all files of it to the workspace
      else
        snapshot_id = repos.history(argu)[-1]
        snapshot_obj = repos.get_snapshot(snapshot_id)
        snapshot_obj.files do |fff|
          @files.push(fff)
          path = fff.path
          content = RevLog.get_file(fff.history_hash_ids[-1])
          self.class.writeFile(path,content)
        end
      end
    end

    def status()
      adds = []
      deletes = []
      edits = []
      if @branch_name != ''
        snapshot_id = repos.history(@branch_name)[-1]
        snapshot_obj = repos.get_snapshot(snapshot_id)
        snapshot_obj.files do |x|
          idx = @files.index(x)
          if idx != nil
            diff = RevLog.diff_files(@files[idx].hash, x.hash)
            if diff.length > 0
              edits.push(x)
            end
          else
            deletes.push(x)
          end
        end
        @files.each do |x|
          if snapshot_obj.files.index(x) == nil
            adds.push(x)
          end
        end
      else
        # if @branch_name is empty, it is initial state, so every file in @files is newly added
        @files.each do |x|
          adds.push(x)
        end
      end # end of if @branch_name != ''
      return [adds, edits, deletes]
    end
  end
end

