# workspace module - linfeng and qiguang


module Copernicium
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

    # returns most recent file id in the snapshot it was saved in
    def last() @history.last end
  end # FileObj


  module Workspace
    include Repos # needed for keeping track of history
    def Workspace.setup
      @@cwd = Dir.pwd
      @@root = (noroot?? @@cwd : getroot)
      @@root.sub!(@@cwd, '.')
      @@copn = File.join(@@root, '.cn')
      @@snap = File.join(@@copn, 'snap')
      @@revs = File.join(@@copn, 'revs')
      RevLog.setup @@root
      Repos.setup @@root
      @@files = Repos.current_files
      @@branch = Repos.current

    end

    # create a new copernicium project
    def Workspace.create_project(location = Dir.pwd, branch = 'master')
      Dir.mkdir location unless Dir.exist? location
      Dir.chdir location

      # create our copernicium folders
      @@copn = File.join('.', '.cn')
      @@snap = File.join(@@copn, 'snap')
      @@revs = File.join(@@copn, 'revs')
      @@head = File.join(@@copn, 'branch')
      @@hist = File.join(@@copn, 'history')
      Dir.mkdir(@@copn) unless Dir.exist?(@@copn)
      Dir.mkdir(@@snap) unless Dir.exist?(@@snap)
      Dir.mkdir(@@revs) unless Dir.exist?(@@revs)

      # make default branch, history
      hist = YAML.dump({branch => []})
      File.write @@head, branch
      File.write @@hist, hist

      if Dir.exist?(@@copn)
        location # return where we made the repo
      else # something has gone horribly wrong
        raise 'Could not create or find a Copernicium folder (.cn).'.red
      end
    end


    # PROJECT HELPERS
    #
    # find  the root .cn folder, or return nil if it doesnt exist
    def getroot
      cwd = Dir.pwd
      max = 0
      def more_folders() Dir.pwd != '/' end
      def root_found() Dir.exist? File.join(Dir.pwd, '.cn') end
      while max < 10 && more_folders && !root_found
        Dir.chdir(File.join(Dir.pwd, '..'))
        max += 1
      end

      if root_found # return where cn was found
        cnroot = Dir.pwd
        Dir.chdir(cwd)
        cnroot
      else # directory not found
        Dir.chdir(cwd)
        nil
      end
    end

    # tells us whether we are in a cn project or not
    def noroot?() getroot.nil? end


    # WORKSPACE MANAGEMENT
    #
    def Workspace.indexOf(x)
      index = -1
      @@files.each_with_index do |e,i|
        if e.path == x
          index = i
          break
        end
      end
      index
    end

    # if include all the elements in list_files
    def Workspace.include?(files)
      files.any? { |x| indexOf(x) == -1 }
    end

    # get all files currently in workspace, except folders and .cn/*
    def Workspace.working_files
      Dir[ File.join(@@root, '**', '*') ].reject do |p|
        File.directory? p || p.include?(@@copn)
      end
    end

    # Clear the workspace
    def Workspace.clear
      @@files.each{ |x| File.delete(x.path) }
      @@files = []
    end

    # reset first: delete them from disk and reset @@files
    def Workspace.clean(comm = UIComm.new(rev: Repos.current_head))
      if comm.files.nil? # reset everything
        Workspace.clear
      else # files are not nil
        # exit if the specified files arent in workspace
        return unless (self.include? comm.files)

        # the actual action, delete all of them from the workspace first
        comm.files.each do |x|
          idx = indexOf(x)
          File.delete(x)
          @@files.delete_at(idx) unless idx == -1
        end
      end

      Workspace.checkout
    end

    def Workspace.commit_file(x)
      if indexOf(x) == -1
        hash = RevLog.add_file(x, File.read(x))
        fobj = FileObj.new(x, [hash,])
        @@files.push(fobj)
      else # file exists
        hash = RevLog.add_file(x, File.read(x))
        if @@files[indexOf(x)].last != hash
          @@files[indexOf(x)].history << hash
        end
      end
    end

    # commit a list of files or the entire workspace to make a new snapshot
    def Workspace.commit(comm = UIComm.new)
      if comm.files.nil? # commit everything
        Workspace.working_files.each { |x| Workspace.commit_file(x) }
      else # else just commit certain files
        # iterate through each file path specified in comm.files
        # check whether that file exist in the disk first
        comm.files.each do |x|
          if File.exist? x
            Workspace.commit_file(x)
          else
            puts 'Cannot commit, file does not exist: '.yel + x
          end
        end
      end
      Repos.make_snapshot(@@files, comm.cmt_msg) # return snapshot id
    end

    # takes in a snapshot id, returns workspace to that snapshot
    def Workspace.checkout(comm = UIComm.new(rev: Repos.current_head))
      if !Repos.has_snapshots? # dont checkout
        raise 'No snapshots yet! Commit something before checkout.'.red
      elsif comm.rev.nil? ## assume last
        comm.rev = Repos.current_head
      else # assume its a revision id
        snap = Repos.get_snapshot(comm.rev)
        return -1 if snap.files.nil?
        snap.files.each do |file|
          idx = indexOf(file.path)
          if  idx == -1
            @@files << file
          else
            @@files[idx] = file
          end
          content = RevLog.get_file(file.last)
          File.write(file.path, content)
        end
      end
    end

    # wrapper for Repos merge_snapshot, update workspace with result
    # returns [{path => content}, [conflicting paths]]
    # todo update workspace with result
    # todo return any conflicting files
    def Workspace.merge(id)
      Repos.merge_snapshot(id)
    end

    def Workspace.status
      added = []
      edits = []
      remov = []
      Workspace.working_files.each do |f|
        idx = indexOf(f)
        if idx < 0 # new file
          added << f
        else # changed file?
          x2 = File.read(f) # get the current version
          x1 = RevLog.get_file(@@files[idx].last)
          edits << f if x1 != x2
        end
      end

      # any deleted files from the last commit?
      @@files.each { |f| remov << f.path unless (working_files.include? f.path) }

      [added, edits, remov]
    end
  end # Workspace
end # Copernicium

