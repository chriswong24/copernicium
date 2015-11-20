# repos module

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



module Repos

  class Repos
    def initialize()
    # Create manifest
    # Create current
	@snapshotsIDs = []
	@snapID = -1
	@snapShots= []
    end
    
    def make_snapshot(file_array)
    # Return hash ID of snapshot
	@snapID = @snapID + 1
	@snapShots.push(file_array)
	@snapshotsIDs.push(@snapID)
        return @snapID
    end

    def get_snapshot(snapshot_id)
	return @snapShots[snapshot_id]
    end
    
    def history(branch_name)
    # Return array of snapshot IDs
    	return @snapshotsIDs
    end
    
    
  end
end


