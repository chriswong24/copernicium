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


  # todo - @@files really should be a Hash, with paths as keys, then rather than
  # using indices.
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
      @@files.each_with_index do |f, i|
        return i if f.path == x
      end
      nil # x is not included in @@files
    end

    # get array of filenamess currently in workspace, except folders and .cn/*
    # todo - include files and files that start with a dot (.)
    def Workspace.working_files
      (Dir[ File.join(@@root, '**', '*') ].reject do |p|
        File.directory? p || p.include?(@@copn)
      end).map do |p|
        p.sub!(/^\.\//, '') # delete leading ./
      end
    end

    # Clear the workspace
    def Workspace.clear
      @@files.each{ |x| File.delete(x.path) }
      @@files = []
    end

    def Workspace.clean(comm = UIComm.new)
      if comm.files.nil? # reset everything
        Workspace.clear
      else # files are not nil
        comm.files.each do |x|
          idx = indexOf(x)
          if idx.nil?
            puts "Cannot clean #{x}:".yel + " does not exist in snapshot"
          else
            @@files.delete_at(idx)
            File.delete(x)
          end
        end
      end
      Workspace.checkout comm # cleanse state
    end

    # takes in a snapshot id, returns workspace to that snapshot
    def Workspace.checkout(comm = UIComm.new)
      if ! Repos.has_snapshots? # dont checkout
        raise 'No snapshots yet! Commit something before checkout.'.red
      elsif comm.rev.nil? # assume last
        comm.rev = Repos.current_head
      end # now assume its a revision id
      snap = Repos.get_snapshot(comm.rev)
      snap.files.each do |file|
        idx = indexOf(file.path)
        if idx.nil?
          @@files << file
        else
          @@files[idx] = file
        end
        content = RevLog.get_file(file.last)
        File.write(file.path, content)
      end
    end

    def Workspace.commit_file(x)
      puts 'Committing: '.grn + x
      added, edits, remov = Workspace.status
      if added.include? x
        hash = RevLog.add_file(x, File.read(x))
        @@files.push(FileObj.new x, [hash])
      elsif edits.include? x
        hash = RevLog.add_file(x, File.read(x))
        @@files[indexOf x].history << hash
      elsif remov.include? x
        @@files.delete_at(indexOf x)
      else
        #puts 'Failed, no changes: '.yel + x
      end
    end

    # commit a list of files or the entire workspace to make a new snapshot
    def Workspace.commit(comm = UIComm.new)
      if comm.files.nil? # commit everything
        Workspace.working_files.each { |x| Workspace.commit_file(x) }
      else comm.files.each do |x|
          if File.exist? x
            Workspace.commit_file(x)
          else
            puts "Cannot commit #{x}:".yel + " file does not exist"
          end
        end
      end
      Repos.make_snapshot(@@files, comm.cmt_msg) # return snapshot id
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
      working_files.each do |f|
        idx = indexOf(f)
        if idx.nil? # new file
          added << f
        else # changed file
          edits << f if File.read(f) != RevLog.get_file(@@files[idx].last)
        end
      end

      # any deleted files from the last commit?
      remov = @@files.map(&:path) - working_files

      [added, edits, remov]
    end
  end # Workspace
end # Copernicium

