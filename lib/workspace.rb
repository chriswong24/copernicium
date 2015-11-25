# This is the workspace module
# The functions are clean, commit, checkout and status

require 'singleton'
require 'pathname'
require_relative 'RevLog'
require_relative 'repos'

module Copernicium
  class FileObj
    attr_reader :path, :history_hash_ids
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
  end

  class Workspace
    def writeFile(path, content)
      f = open(path, 'w')
      f.write(content)
      f.close
    end

    def readFile(path)
      f = open(path, 'r')
      txt = f.read
      f.close
      txt
    end

    #private_class_method: writeFile
    #private_class_method: readFile

    def initialize
      @files = []
      @branch_name = 'master'
      @revlog = Copernicium::RevLog.new('.')
      @repos = Copernicium::Repos.new
      @root = "workspace"
      if !File.directory?(@root)
        Dir.mkdir(@root)
      end
    end

    def indexOf(x)
      index = -1
      @files.each_with_index do |e,i|
        if e.path == x
          index = i
          break
        end
      end
      index
    end

    # if include all the elements in list_files
    def include?(list_files)
      list_files.each do |x|
        if indexOf(x) == -1
          return false
        end
      end
      true
    end

    # if list_files is nil, then rollback the list of files from the branch
    # or rollback to the entire branch head pointed
    def clean(comm)
      list_files = comm.files
      if list_files.nil? # reset first: delete them from disk and reset @files
        @files.each{|x| File.delete(x.path)}
        @files = []
        # restore it with checkout() if we have had a branch name
        if @branch_name != ''
          # or it is the initial state, no commit and no checkout
          return checkout(@branch_name)
        else
          return 0
        end

      else #list_files are not nil
        # check that every file need to be reset should have been recognized by the workspace
        #workspace_files_paths = @files.each{|x| x.path}
        return -1 if (self.include? list_files) == false

        # the actual action, delete all of them from the workspace first
        list_files.each do |x|
          File.delete(x)
          idx = indexOf(x)
          if !idx==-1
            @files.delete_at(idx)
          end
        end

        # if we have had a branch, first we get the latest snapshot of it
        # and then checkout with the restored version of them
        if @branch_name != ''
          return checkout(list_files)
        end
      end
    end

    # commit a list of files or the entire workspace to make a new snapshot
    def commit(comm)
      list_files = comm.files
      if list_files != nil
        list_files.each do |x|
          if indexOf(x) == -1
            content = readFile(x)
            hash = @revlog.add_file(x, content)
            fobj = FileObj.new(x, [hash,])
            @files.push(fobj)
          else
            content = readFile(x)
            hash = @revlog.add_file(x, content)
            if @files[indexOf(x)].history_hash_ids[-1] != hash
              @files[indexOf(x)].history_hash_ids << hash
            end
          end
        end
      end
      return @repos.make_snapshot(@files)
    end

    def checkout(comm)
      argu = comm.files
      # if argu is an Array Object, we assume it is a list of files to be added to the workspace
      if argu != nil
        # we add the list of files to @files regardless whether it has been in it.
        # that means there may be multiple versions of a file.
        list_files = argu
        snapshot_id = @repos.history(argu)[-1]
        list_files_last_commit = @repos.get_snapshot(snapshot_id)
        list_files_last_commit.each do |x|
          if list_files.include? x.path
            path = x.path
            content = @revlog.get_file(x.history_hash_ids[-1])
            idx = indexOf(x.path)
            if  idx == -1
              @files.push(x)
            else
              @files[idx] = x
            end
            writeFile(path,content)
          end
        end
        # if argu is not an Array, we assume it is a String, representing the branch name
        # we first get the last snapshot id of the branch, and then get the commit object
        # and finally push all files of it to the workspace
      else
        argu = comm.rev #branch name
        snapshot_id = @repos.history(argu)[-1]
        snapshot_obj = @repos.get_snapshot(snapshot_id)
        snapshot_obj.each do |fff|
          idx = indexOf(fff.path)
          if  idx == -1
            @files.push(fff)
          else
            @files[idx] = fff
          end
          path = fff.path
          content = @revlog.get_file(fff.history_hash_ids[-1])
          writeFile(path,content)
        end
      end
    end

    def status(comm)
      adds = []
      deletes = []
      edits = []
      wsFiles = Dir[ File.join(@root, '**', '*') ].reject { |p| File.directory? p }
      wsFiles.each do |f|
        idx = indexOf(f)
        if idx != -1
          x1 = @revlog.get_file(@files[idx].history_hash_ids[-1])
          x2 = readFile(f)
          if x1 != x2
            edits.push(f)
          end
        else
          adds.push(f)
        end
      end
      @files.each do |f|
        if ! (wsFiles.include? f.path)
          deletes.push(f.path)
        end
      end
      return [adds, edits, deletes]
    end
  end
end

