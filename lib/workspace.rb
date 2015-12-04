# workspace module - linfeng and qiguang

module Copernicium
  # helper methods for file IO
  def writeFile(path, content)
    f = open(path, 'w')
    f.write(content)
    f.close
  end

  # helper methods for file IO
  def readFile(path)
    f = open(path, 'r')
    txt = f.read
    f.close
    txt
  end

  # find  the root .cn folder
  def getroot
    cwd = Dir.pwd
    max = 0
    def notroot() Dir.pwd != '/' end
    def notcn() File.exists? File.join(Dir.pwd, '.cn') end
    while max < 10 && notroot && notcn
      Dir.chdir(File.join(Dir.pwd, '..'))
      max += 1
    end

    if notcn # return where cn was found
      cnroot = Dir.pwd
      Dir.chdir(cwd)
      cnroot
    else # directory not found
      Dir.chdir(cwd)
      nil
    end
  end

  class FileObj
    attr_reader :path, :history
    def initialize(path, ids)
      @history = ids
      @path = path
    end

    # returns most recent file id in the snapshot it was saved in
    def last
      @history.last
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
    attr_reader :repos, :revlog
    def initialize(bname = 'master')
      @files = []
      @cwd = Dir.pwd
      @root = getroot
      Dir.chdir(@cwd)
      @root = @cwd if @root.nil?
      @cwd.sub!(@root, '.')
      @branch = bname
      @repo = Repos.new(@cwd)
      @revlog = RevLog.new(@cwd)

      pexit 'Copernicium folder (.cn) not found.', 1 if @root.nil?
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
    def include?(files)
      files.each { |x| return false if indexOf(x) == -1 }
      true
    end

    # get all files currently in workspace
    def ws_files
      Dir[ File.join(@root, '**', '*') ].reject { |p| File.directory? p or File.join(@root,'.cn').include? p == false }
    end

    # Clear the current workspace
    def clear
      @files.each{ |x| File.delete(x.path) }
      @files = []
    end

    # reset first: delete them from disk and reset @files
    # restore it with checkout() if we have had a branch name
    # or it is the initial state, no commit and no checkout
    # if list_files is nil, then rollback the list of files from the branch
    # or rollback to the entire branch head pointed
    def clean(comm)
      if comm.files.empty?
        clear # reset, checkout last commit
        checkout
      else # files are not nil

        # exit if the specified file is not in the workspace
        return -1 if (self.include? comm.files) == false

        # the actual action, delete all of them from the workspace first
        comm.files.each do |x|
          File.delete(x)
          idx = indexOf(x)
          @files.delete_at(idx) if !idx == -1
        end

        # if we have had a branch, first we get the latest snapshot of it
        # and then checkout with the restored version of them
        checkout
      end
    end

    # commit a list of files or the entire workspace to make a new snapshot
    def commit(comm)
      unless ws_files.empty?
        ws_files.each do |x|
          if indexOf(x) == -1
            content = readFile(x)
            hash = @revlog.add_file(x, content)
            fobj = FileObj.new(x, [hash,])
            @files.push(fobj)
          else
            content = readFile(x)
            hash = @revlog.add_file(x, content)
            if @files[indexOf(x)].history[-1] != hash
              @files[indexOf(x)].history << hash
            end
          end
        end
      end
      @repo.make_snapshot(@files) # return snapshot id
    end

    def checkout(comm = UIComm.new(rev: @branch))
=begin
      # just support branches for now
      # if argu is an Array Object, we assume it is a list of files to be added
      # # to the workspace # we add the list of files to @files regardless
      # whether it has been in # it. that means there may be multiple versions
      # of a file.
      unless comm.files.nil?
        list_files = comm.files
        returned_snapshot = @repo.get_snapshot(@repo.history.last)
        list_files_last_commit = returned_snapshot.files
        list_files_last_commit.each do |x|
          if list_files.include? x.path
            content = @revlog.get_file(x.history.last)
            idx = indexOf(x.path)
            if  idx == -1
              @files << x
            else
              @files[idx] = x
            end
            writeFile(x.path, content)
          end
        end
      else # if argu is not an Array, we assume it is a String, representing the
      end
=end

      clear # reset workspace

      # Dec. 3th, 2015 by Linfeng, 
      # for this command, the comm.rev should be a string representing the branch name
      @branch = comm.rev
      @repos.update(@branch)

      # we first get the last snapshot id of the branch, and then get the commit
      # object and finally push all files of it to the # workspace
      @repo.get_snapshot(@repo.history.last).files.each do |file|
        idx = indexOf(file.path)
        if  idx == -1
          @files << file
        else
          @files[idx] = file
        end
        content = @revlog.get_file(file.history.last)
        writeFile(file.path, content)
      end
    end

    # wrapper for Repos merge_snapshot, update workspace with result
    def merge(id)
      @repos.merge_snapshot(id)
      # returns [{path => content}, [conflicting paths]]
      # todo update workspace with result
      # todo return any conflicting files
    end

    def status(comm)
      added = []
      edits = []
      remov = []
      ws_files.each do |f|
        idx = indexOf(f)
        if idx == -1 # new file
          added << f
        else # changed file?
          x2 = readFile(f) # get the current version
          x1 = @revlog.get_file(@files[idx].history.last)
          edits << f if x1 != x2
        end
      end

      # any deleted files from the last commit?
      @files.each { |f| remov << f.path unless (ws_files.include? f.path) }

      [added, edits, remov]
    end
  end
end

