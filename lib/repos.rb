# Repos Top Level Function Definitions (Logan)

# make_snapshot: Creates new snapshot from current files and versions
#   in - array of file objects. file object = array of all versions:
#   {id, content}
#   out - hash id of snapshot
#   merge_snapshot: merge in a branch’s history into the current branch. if
#in - branch name
#out - [{path => content}, [conflicting paths]]
#   get_snapshot: Return a specific snapshot
#in - snapshot id
#out - snapshot object
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
      @@files = files
      @@id = id
    end
  end

  module Repos
    include RevLog # needs diffing and merging
    # read in file of snapshots (.cn/history)
    # check the current branch (.cn/branch)
    def setup(root = Dir.pwd, branch = 'master')
      @@root = root
      @@copn = File.join(@@root, '.cn')
      @@bpath = File.join(@@copn, 'branch')
      @@spath = File.join(@@copn, 'history')

      # check if files exist, read them
      if File.exist?(@@spath) && File.exist?(@@bpath)
        @@snaps = Marshal.load readFile(@@spath)
        @@branch = readFile(@@bpath)
      else # use defaults
        @@snaps = {branch => []}
        @@branch = branch
      end
    end

    # returns the hash if of an object
    def hasher(obj)
      Digest::SHA256.hexdigest Marshal.dump(obj)
    end

    # Return string array of what branches we have
    def branches
      @@snaps.keys
    end

    # Create snapshot, and return hash ID of snapshot
    def make_snapshot(files = [])
      snap = Snapshot.new(files)
      snap.id = hasher snap
      @@snaps[@@branch] << snap

      # Update snaps file
      update_snap
      snap.id
    end

    # helper to write a snapshot, saving a new commit
    def update_snap
      writeFile(@@spath, Marshal.dump(@@snaps))
    end

    # Select all elements of array1 that are not in array2
    def set_diff(array1, array2)
      array1.select { |x| !array2.any? { |y| x == y } }
    end

    # todo - Check to make sure id is from a different branch
    # Merge the target snapshot into HEAD snapshot of the current branch
    def merge_snapshot(id)
      # run diff to get conflicts
      current = @@snaps[@@branch].last
      difference = diff_snapshots(current.id, id)
      conflicts = difference[1]

      # if no conflicts, add new snapshot to head of current branch
      if conflicts.empty?
        make_snap current.files + set_diff(get_snapshot(id).files, current.files)
      end

      # returns [{path => content}, [conflicting paths]]
      difference
    end

    # Find snapshot, return snapshot given id
    def get_snapshot(id)
      found_index = nil
      found_branch = nil
      branches.each do |x|
        found_index = @@snaps[x].index { |y| y.id == id }
        found_branch = x if found_index
      end
      if found_index
        @@snaps[found_branch][found_index]
      else
        raise "Snapshot not found."
      end
    end

    # Return array of snapshot IDs
    def history(branch_name = nil)
      snapids = []
      if branch_name.nil?
        @@snaps[@@branch].each {|x| snapids << x.id }
      else
        @@snaps[branch_name].each{|x| snapids << x.id }
      end
      snapids
    end

    # Find snapshot, delete from snaps/memory
    def delete_snapshot(id)
      @@snaps[@@branch].delete_if { |x| x.id == id }
      update_snap
    end

    #diff_snapshots needs to catch both files in snap1 that aren’t and snap2 and
    #find individual differences in between the files by calling RevLogs diffy.
    # Return same thing as merge
    # note: id1 gets priority for history
    def diff_snapshots(id1, id2)
      new_files = []
      conflicts = []
      diffed = {}

      # todo - Put in error catching
      files1 = get_snapshot(id1).files
      files2 = get_snapshot(id2).files
      new_files = set_diff(files2, files1)

      files1.each do |file|
        # find corresponding file object
        f2_index = files2.index{ |y| y == file }

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

      # adding each new file from the merged snapshot
      new_files.each { |x| diffed[x.path] = get_file(x.last) }

      # returns [{path => content}, [conflicting paths]]
      [diffed, conflicts]
    end

    # todo - convert this to mod
    #attr_reader :snaps, :branch

    # BRANCHING

    # Return hash ID of new branch
    def make_branch(branch)
      @@snaps[branch] = @@snaps[@@branch]
      @@branch = branch
      # todo - make this actually hash the entire @@snaps[branch]
      # eg: hasher @@snaps[branch]
      hasher @@branch
    end

    def update_branch(branch)
      writeFile(@@bpath, branch)
      @@branch = branch
    end

    def delete_branch(branch)
      @@snaps.delete(branch)
    end
  end # repo class
end

