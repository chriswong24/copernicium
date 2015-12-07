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
# note: @@history is a hash array of snapshot ids, which is saved as
# .cn/history to persist between calls to the copernicium tool

module Copernicium
  class Snapshot
    attr_accessor :id, :files, :msg, :date
    # todo - doesnt support merging. consider adding parents field
    def initialize(files = [], msg = 'null', date = nil)
      @date = (date.nil?? DateTime.now : date)
      @files = files
      @msg = msg

      # hash self and assign as the id value
      @id = Digest::SHA256.hexdigest Marshal.dump(self)
    end

    def time
      @date.strftime("%m/%d/%Y %I:%M%p")
    end
  end

  module Repos
    include RevLog # needs diffing and merging
    # read in file of snapshot ids (.cn/history)
    # check the current branch (.cn/branch)
    def Repos.setup(root = Dir.pwd)
      @@copn = File.join(root, '.cn')
      @@snap = File.join(@@copn, 'snap')
      @@head = File.join(@@copn, 'branch')
      @@hist = File.join(@@copn, 'history')

      # read history from disk
      @@branch = File.read(@@head)
      @@history = YAML.load File.read(@@hist)
      @@brsnaps = Repos.get_branch @@branch
    end

    # unit testing version - create folders for this code
    def Repos.setup_tester(root = Dir.pwd, branch = 'master')
      @@copn = File.join(root, '.cn')
      @@snap = File.join(@@copn, 'snap')
      @@revs = File.join(@@copn, 'revs')
      @@head = File.join(@@copn, 'branch')
      @@hist = File.join(@@copn, 'history')

      # create folders for testing this module
      Dir.mkdir(@@copn) unless Dir.exist?(@@copn)
      Dir.mkdir(@@snap) unless Dir.exist?(@@snap)
      Dir.mkdir(@@revs) unless Dir.exist?(@@revs)

      # default new
      @@branch = branch
      @@history = {branch => []}
      RevLog.setup
    end

    # check whether a specific branch exists
    def Repos.has_branch?(branch)
      Repos.branches.include? branch
    end

    # check if any snapshots exist for the current branch
    def Repos.has_snapshots?
      not Repos.history(@@branch).empty?
    end

    # Return hash of an object
    def Repos.hasher(obj)
      Digest::SHA256.hexdigest Marshal.dump(obj)
    end

    def hash_array
      Hash.new {[]}
    end

    # Create and return snapshot id
    def Repos.make_snapshot(files = [], msg = 'nil')
      snap = Snapshot.new(files, msg)
      @@history[@@branch] << snap.id

      # Update snaps file
      update_snap snap
      update_history
      snap.id
    end

    # helper to write a snapshot, saving a new commit
    # marshal serializes the class instance to a string
    def Repos.update_snap(snap)
      File.write File.join(@@snap, snap.id), YAML.dump(snap)
    end

    # helper to add snap to history
    def Repos.update_history
      File.write @@hist, YAML.dump(@@history) # write history
    end

    # Merge the target snapshot into HEAD snapshot of the current branch
    # todo - Check to make sure id is from a different branch
    def Repos.merge_snapshot(id)
      # run diff to get conflicts
      current = @@history[@@branch].last
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
      @@history.each do |branch, snapids|
        snapids.each do |snapid|
          return YAML.load_file(File.join(@@snap, id)) if snapid == id
        end
      end

      raise "Repos: snapshot #{id} not found in this repo.".red
    end

    # Return array of snapshot IDs
    def Repos.history(branch = nil)
      if branch.nil? # return a list of unique all commits
        (@@history.inject([]) { |o, x| o + x.last }).uniq
      elsif Repos.has_branch? branch # just return the stored history
        @@history[branch]
      else # no commits yet
        []
      end
    end

    # Find snapshot, delete from snaps/memory
    def Repos.delete_snapshot(id)
      @@history[@@branch].delete_if { |x| x == id }
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
          content1 = RevLog.get_file(id1)
          content2 = RevLog.get_file(id2)

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


    # ADDITIONAL MODULE ACCESS INTERFACES
    #
    # return the current branch we are on now
    def current() @@branch end

    # return the snap id of branch head
    def current_head() @@history[@@branch].last end

    # return the array of our branches snapshots
    def current_snaps() @@brsnaps end

    # return the files in the latest snapshot
    def current_files() Repos.has_snapshots?? @@brsnaps.last.files : [] end

    # Return string array of what branches we have
    def Repos.branches() @@history.keys end


    # BRANCHING FUNCTIONALITY
    #
    # Create and return hash ID of new branch
    def Repos.make_branch(branch)
      @@history[branch] =  (@@history[@@branch].nil?? [] : @@history[@@branch])
      @@branch = branch
      update_history
      hasher @@history[branch]
    end

    def Repos.update_branch(branch)
      File.write(@@head, branch)
      @@branch = branch
    end

    # From the branch names, get the history, ant build the array of snapshots
    # This is different than the history branch which just contains ids
    def Repos.get_branch(branch)
      Repos.history(branch).inject([]) do |hist, snapid|
        hist << Repos.get_snapshot(snapid)
      end
    end

    # todo - also delete snapshots unique to this branch
    def Repos.delete_branch(branch)
      @@history.delete(branch)
      update_history
    end
  end # Repos
end # Copernicium

