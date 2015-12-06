# Repos Top Level Function Definitions (Logan)

# make_snapshot: Creates new snapshot from current files and versions
#   in - array of file objects. file object = array of all versions:
#   {id, content}
#   out - hash id of snapshot
# merge_snapshot: merge in a branch’s history into the current branch. if
#   in - branch name
#   out - [{path => content}, [conflicting paths]]
# get_snapshot: Return a specific snapshot
#   in - snapshot id
#   out - snapshot object
# restore_snapshot: Set current file versions to specified snapshot
#   in - id of target snapshot
#   out - Comm object with status
# history: Returns ids for all snapshots
#   in - branch name
#   out - Array of snapshot ids
# delete_snapshot: delete specified a snapshot
#   in - target snapshot
#   out -  Comm object with status
# diff_snapshots: Returns diff between two different snapshots
#   in - two ids of snapshots to perform diff on
#   out - list of filenames and versions
# make_branch: make a new branch
#   in - branch name
#   out - hash id of new branch
# delete_branch: delete a branch
#   in - branch name
#   out - exit status code

module Copernicium
  class Snapshot
    attr_accessor :id, :files, :msg
    # id is computed after creation
    def initialize(files = [], msg)
      @files = files
      @msg = msg
      @id = id
    end
  end

  module Repos
    include RevLog # needs diffing and merging
    # check the current branch (.cn/branch)
    # read in file of snapshots (.cn/history)
    def Repos.setup(root = Dir.pwd, branch = 'master')
      @@root = root
      @@copn = File.join(@@root, '.cn')
      @@repo = File.join(@@copn, 'repo')
      @@snap = File.join(@@copn, 'snap')
      @@branchhead = File.join(@@copn, 'branch')
      @@repo_path = File.join(@@repo, branch)
      Dir.mkdir(@@copn) unless Dir.exist?(@@copn)
      Dir.mkdir(@@repo) unless Dir.exist?(@@repo)
      Dir.mkdir(@@snap) unless Dir.exist?(@@snap)

      # check if files exist, read them
      if File.exist?(@@repo_path) && File.exist?(@@branchhead)
        @@branches = Marshal.load readFile(@@repo_path)
        @@branch = readFile(@@branchhead)
      else # use defaults
        @@branches = {branch => []}
        @@branch = branch
      end

      # check if files exist, read them
      if File.exist?(@@repo_path) && File.exist?(@@branchhead)
        @@branches = Marshal.load readFile(@@repo_path)
        @@branch = readFile(@@branchhead)
      else # use defaults
        @@branches = {branch => []}
        @@branch = branch
      end
    end

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

    # check if any snapshots exist, if not exit
    def Repos.has_snapshots?
      ! Repos.history(@@branch).empty?
    end

    def Repos.hash_array
      Hash.new {[]}
    end

    # returns the hash of an object
    def Repos.hasher(obj)
      Digest::SHA256.hexdigest Marshal.dump(obj)
    end

    # Return string array of what branches we have
    def Repos.branches
      @@branches.keys
    end

    # Create and return snapshot
    def Repos.make_snapshot(files = [], msg = '')
      snap = Snapshot.new(files, msg)
      snap.id = hasher snap
      @@branches[@@branch] << snap

      # Update snaps file
      update_snap snap
      update_history
      snap.id
    end

    # helper to write a snapshot, saving a new commit
    def Repos.update_snap(snap)
      writeFile File.join(@@snap, snap.id), Marshal.dump(snap) # write snapshot
    end

    # helper to add snap to history
    def Repos.update_history
      writeFile @@repo_path, Marshal.dump(@@branches) # write history
    end

    # todo - Check to make sure id is from a different branch
    # Merge the target snapshot into HEAD snapshot of the current branch
    def Repos.merge_snapshot(id)
      # run diff to get conflicts
      current = @@branches[@@branch].last
      difference = diff_snapshots(current.id, id)
      conflicts = difference[1]

      if conflicts.empty? # make snapshot
        make_snap current.files + diffset(get_snapshot(id).files, current.files)
      end

      # returns [{path => content}, [conflicting paths]]
      difference
    end

    # Find snapshot and return snapshot from id
    def Repos.get_snapshot(id)
      @@branches.keys.each do |br|
        @@branches[br].each do |snap_id|
          # If found, read from disk and return
          if snap_id == id
            return Marhsall.load(File.join(@@snap, snap_id))
          end
        end
      end

      raise "Snapshot not found in this repo."
    end

    # Return array of snapshot IDs
    def Repos.history(branch = nil)
      snapids = []
      if branch.nil?
        @@branches[@@branch].each { |x| snapids << x.id }
      elsif
        @@branches[branch].each { |x| snapids << x.id }
      end
      snapids
    end

    # Find snapshot, delete from snaps/memory
    def Repos.delete_snapshot(id)
      @@branches[@@branch].delete_if { |x| x.id == id }
      update_snap
    end

    #diff_snapshots needs to catch both files in snap1 that aren’t and snap2 and
    #find individual differences in between the files by calling RevLogs diffy.
    # Return same thing as merge # note: id1 gets priority for history
    def Repos.diff_snapshots(id1, id2)
      new_files = []
      conflicts = []
      diffed = {}
      files1 = get_snapshot(id1).files
      files2 = get_snapshot(id2).files
      new_files = diffset(files2, files1)

      # adding each new file from the merged snapshot
      new_files.each { |x| diffed[x.path] = get_file(x.last) }

      # handle files that exist in both snapshots
      files1.each do |file|
        # find corresponding file object
        f2_index = files2.index { |y| y == file }

        # If found, check if same content
        unless f2_index.nil?
          id1 = file.last
          id2 = files2[f2_index].last

          # get file contents
          content1 = get_file(id1)
          content2 = get_file(id2)

          # check if the file content for each path is the same
          if content1 == content2
            diffed[file.path] = content1
          else # If not same, diff and add to conflicts
            diffed[file.path] = diff_files(id1, id2)
            conflicts << file.path
          end
        else # not found, use our version
          diffed[file.path] = content1
        end
      end

      # returns [{path => content}, [conflicting paths]]
      [diffed, conflicts]
    end

    # Select all elements of array1 that are not in array2
    def Repos.diffset(array1, array2)
      array1.select { |x| !array2.any? { |y| x == y } }
    end

    # BRANCHING
    def current() @@branches end

    # Return hash ID of new branch
    def Repos.make_branch(branch)
      @@branches[branch] = @@branches[@@branch]
      @@branch = branch
      hasher @@branches[branch]
    end

    def Repos.update_branch(branch)
      writeFile(@@branchhead, branch)
      @@branch = branch
    end

    def Repos.delete_branch(branch)
      @@branches.delete(branch)
    end
  end # Repos
end # Copernicium

