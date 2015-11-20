# repos module

require 'digest'

# Details from this link:
#   https://docs.google.com/document/d/1r3-NquhyRLbCncqTOQPwsznSZ-en6G6xzLbWIAmxhys/edit#heading=h.7pyingf1unu


# Repos Top Level Function Definitions (Logan)

# make_snapshot: Creates new snapshot from current files and versions
#   in - array of file objects. file object = array of all versions: {id, content}
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

module Repos
  class Snapshot
  {
    # contains array of file objects
    # other info? - ID
    # Initialize hash at startup
    # Possible? Or problem with self object?
  
  
  }
  class Manifest
  {
    # snapshots will be list of snapshots
    # a snapshot will be a list of file objects
    # where do we get the file object def???
    # consider defining snapshot object
    
    # Just do list of snapshots

  }
  class Repos
    def initialize()
      # Create manifest
      manifest = []
      # Create current
    end
    
    def make_snapshot(file_array)
      # Return hash ID of snapshot
      Snapshot new_snap(file_array)
      snap_hash = new_snap.hash
      return 1
    end
    
    def restore_snapshot(target_id)
    # Return comm object with status
    end
    
    def history(branch_name)
      # Return array of snapshot IDs
      names_list = []
      manifest.each {|x| names_list.append(x.id)}
      return names_list
    end
    
    def delete_snapshot(target_id)
    # Return comm object with status
    end
    
    def diff_snapshots(id1, id2)
    # Return list of filenames and versions
    end
    
    def make_branch(branch_name)
    # Return hash ID of new branch
    return 2
    end
    
    def delete_branch(branch_name)
    # Exit status code
    end
    
    def clear()
    # Just a placeholder for now
    end
    
  end
end


