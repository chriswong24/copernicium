# Repos Top Level Function Definitions (Logan)

# make_snapshot: Creates new snapshot from current files and versions
#   in - array of file objects. file object = array of all versions:
#   {id, content}
#   out - hash id of snapshot
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
# Also do a get_snapshot

module Copernicium
  class Snapshot
    attr_accessor :id, :files
    # id is computed after creation
    def initialize(files = [])
      @files = files
      @id = id
    end
  end

  class Repos
    attr_reader :snaps
    # read in file of snapshots (.cn/history)
    # check the current branch (.cn/branch)
    def initialize(root, branch = 'master')
      @root = root
      @copn = File.join(@root, '.cn')
      @bpath = File.join(@copn, 'branch')
      @spath = File.join(@copn, 'history')

      # check if files exist, read them
      if File.exist?(@spath) && File.exist?(@bpath)
        @snaps = Marshal.load readFile(@spath)
        @branch = readFile(@bpath)
      else # use defaults
        @snaps = {branch => []}
        @branch = branch
      end
    end

    # returns the hash if of an object
    def hasher(obj)
      Digest::SHA256.hexdigest Marshal.dump(obj)
    end

    # array of hashes constructor
    def hash_array
      Hash.new {[]}
    end

    # Return string array of what branches we have
    def branches
      @snaps.keys
    end

    def update_snap
      writeFile(@spath, Marshal.dump(@snaps))
    end

    def update_branch
      writeFile(@bpath, @branch)
    end

    # Create snapshot, and return hash ID of snapshot
    def make_snapshot(files = [])
      snap = Snapshot.new(files)
      snap.id = hasher snap
      @snaps[@branch] << snap

      # Update snaps file
      update_snap
      snap.id
    end

    # Find snapshot, return snapshot (or just contents) given id
    def get_snapshot(id)
      found_index = @snaps[@branch].index { |x| x.id == id }
      if found_index
        @snaps[@branch][found_index]
      else
        Snapshot.new
      end
    end

    # Return comm object with status
    # change files in workspace back to specified commit
    # get clear the current workspace
    # revert back to given commit
    def restore_snapshot(id)
      # todo
    end

    # Return array of snapshot IDs
    def history(branch_name = nil)
      snapids = []
      if branch_name.nil?
        @snaps[@branch].each {|x| snapids << x.id }
      else
        @snaps[branch_name].each{|x| snapids << x.id }
      end
      snapids
    end

    # Find snapshot, delete from snaps/memory
    def delete_snapshot(id)
      @snaps[@branch].delete_if { |x| x.id == id }
      update_snap
    end

    #diff_snapshots needs to catch both files in snap1 that aren’t and snap2 and
    #find individual differences in between the files by calling RevLogs diffy.
    # Return list of filenames and versions
    def diff_snapshots(id1, id2)
      diffed = []

      # Put in error catching
      files1 = get_snapshot(id1).files
      files2 = get_snapshot(id2).files

      # Find difference between snapshot1 and snapshot2
      files1.each { |x| diffed << x unless !files2.include?(x) }

      diffed
    end

    # Return hash ID of new branch
    def make_branch(branch)
      @snaps[branch] = @snaps[@branch]
      @branch = branch
      hasher 1
    end

    # Merge the target branch into current
    def merge_branch(branch)
      # todo
    end

    # Exit status code
    def delete_branch(branch)
      @snaps.delete(branch)
    end
  end # repo class
end

