# workspace module - linfeng and qiguang

module Copernicium
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

  class FileObj
    attr_reader :path, :history
    def initialize(path, ids)
      @history = ids
      @path = path
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
    def getroot
      max = 0
      def notroot() Dir.pwd != '/' end
      def notcn() File.exists? File.join(Dir.pwd, '.cn') end
      while max < 10 && notroot && notcn
        Dir.chdir(File.join(Dir.pwd, '..'))
        puts Dir.pwd
        max += 1
      end

      if notcn # return where cn was found
        return Dir.pwd
      else # directory not found
        return nil
      end
    end

    def initialize(bname = 'master')
      @files = []
      @cwd = Dir.pwd
      @root = getroot
      Dir.chdir(@cwd)
      @root = @cwd if @root.nil?
      @cwd.sub!(@root, '.')
      @branch = bname
      @repos = Repos.new
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
      files.each do |x|
        return false if indexOf(x) == -1
      end
      true
    end

    def ws_files
      Dir[ File.join(@root, '**', '*') ].reject { |p| File.directory? p }
    end

    # if list_files is nil, then rollback the list of files from the branch
    # or rollback to the entire branch head pointed
    def clean(comm)
      list_files = comm.files
      if list_files.nil? # reset first: delete them from disk and reset @files
        @files.each{|x| File.delete(x.path)}
        @files = []
        # restore it with checkout() if we have had a branch name
        if @branch != ''
          # or it is the initial state, no commit and no checkout
          comm = UIComm.new(command: 'checkout', rev: @branch)
          return checkout(comm)
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
        if @branch != ''
          return checkout(list_files)
        else
          return 0
        end
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
      @repos.make_snapshot(@files) # return snapshot id
    end

    def checkout(comm)
      # if argu is an Array Object, we assume it is a list of files to be added
      # to the workspace
      argu = comm.files
      if argu != nil
        # we add the list of files to @files regardless whether it has been in
        # it. that means there may be multiple versions of a file.
        list_files = argu
        snapshot_id = @repos.history.last
        returned_snapshot = @repos.get_snapshot(snapshot_id)
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
        # branch name # we first get the last snapshot id of the branch, and
        # then get the commit object # and finally push all files of it to the
        # workspace
        @repos.get_snapshot(@repos.history.last).files.each do |fff|
          idx = indexOf(fff.path)
          if  idx == -1
            @files << fff
          else
            @files[idx] = fff
          end
          content = @revlog.get_file(fff.last)
          writeFile(fff.path, content)
        end
      end
    end

    def status(comm)
      added = edits = remov = []
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

