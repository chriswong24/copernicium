# repos module

# See link for details:
# https://docs.google.com/document/d/1r3-NquhyRLbCncqTOQPwsznSZ-en6G6xzLbWIAmxhys/edit#heading=h.7pyingf1unu

module Repos
  class Repos
    def initialize()
    end
    
    def make_snapshot(file_array)
    # Return hash ID of snapshot
    return 1
    end
    
    def restore_snapshot(target_id)
    # Return comm object with status
    end
    
    def history(branch_name)
    # Return array of snapshot IDs
    return ['a', 'b', 'c']
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
  end
end


