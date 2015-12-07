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
# note: @@branches is a hash array of snapshot ids, which is saved as
# .cn/history to persist between calls to the copernicium tool

module Copernicium
  class Snapshot
    attr_accessor :id, :files, :msg
    # id is computed after creation
    def initialize(files = [], msg)
      @date = DateTime.now
      @files = files
      @msg = msg
      @id = id
    end
  end

  module Repos
    include RevLog # needs diffing and merging
    # check the current branch (.cn/branch)
    # read in file of snapshot ids (.cn/<branches>)
    def Repos.setup(root = Dir.pwd)
      @@copn = File.join(root, '.cn')
      @@snap = File.join(@@copn, 'snap')
      @@head = File.join(@@copn, 'branch')
      @@hist = File.join(@@copn, 'history')

      # read history from disk
      @@branch = File.read(@@head)
      @@branches = Marshal.load File.read(@@hist)
    end

    # unit testing version - create folders for this code
    def Repos.setup_tester(root = Dir.pwd, branch = 'master')
      @@copn = File.join(root, '.cn')
      @@snap = File.join(@@copn, 'snap')
      @@head = File.join(@@copn, 'branch')
      @@hist = File.join(@@copn, 'history')

      # create folders for testing this module
      Dir.mkdir(@@copn) unless Dir.exist?(@@copn)
      Dir.mkdir(@@snap) unless Dir.exist?(@@snap)

      # default new
      @@branch = branch
      @@branches = {branch => []}
    end

    # check if any snapshots exist
    def Repos.has_snapshots?
      not Repos.history(@@branch).empty?
    end

    # returns the hash of an object
    def Repos.hasher(obj)
      Digest::SHA256.hexdigest Marshal.dump(obj)
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
    # marshal serializes the class instance to a string
    def Repos.update_snap(snap)
      File.write File.join(@@snap, snap.id), Marshal.dump(snap)
    end

    # helper to add snap to history
    def Repos.update_history
      File.write @@hist, Marshal.dump(@@branches) # write history
    end

    # Merge the target snapshot into HEAD snapshot of the current branch
    # todo - Check to make sure id is from a different branch
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
        @@branches[br].each do |snapid|
          # If found, read from disk and return
          if snapid == id
            return Marhsall.load(File.join(@@snap, snapid))
          end
        end
      end

      raise "Repos: snapshot not found in this repo.".red
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
      File.delete File.join(@@snap, id)
      update_history
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

    # return the current branch we are on now
    def current() @@branch end

    # Return string array of what branches we have
    def Repos.branches() @@branches.keys end

    # Create and return hash ID of new branch
    def Repos.make_branch(branch)
      @@branches[branch] = @@branches[@@branch]
      @@branch = branch
      update_history
      hasher @@branches[branch]
    end

    def Repos.update_branch(branch)
      File.write(@@head, branch)
      @@branch = branch
    end

    # todo - also delete snapshots unique to this branch
    def Repos.delete_branch(branch)
      @@branches.delete(branch)
      update_history
    end
  end # Repos
end # Copernicium

