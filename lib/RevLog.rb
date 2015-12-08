# Revlog Top Level Function Definitions (Xiangru)
#
# add_file: add a file to the revision history
# in - file name, content
# out - hash id of file (file_id)
#
# delete_file: a delete a file from revision history
# in - file_id
# out - exit status code
#
# diff_files: generate the differences between 2 files
# in - two file_ids
# out - list of differences
#
# get_file: get the contents of a file based on hash id
# in - file_id
# out - content of specified file
#
# hash_file: generate hash id for a given file
# in - file name, content
# out - hashed id
#
# merge: given two files, try to merge them
# in - file_id_1, file_id_2
# out - success and merged file name/content, or failure and conflict

module Copernicium
  module RevLog
    # called when including RevLog
    # dont make any new folders
    def RevLog.setup(root = Dir.pwd)
      @@cop_path = File.join(root, '.cn')
      @@rev_path = File.join(@@cop_path, 'revs')
      @@log_path = File.join(@@cop_path, 'logmap')
      @@hash_path = File.join(@@cop_path, 'hashmap')
      if File.exist?(@@log_path) && File.exist?(@@hash_path)
        @@logmap = hash_array.merge(YAML.load_file(@@log_path))
        @@hashmap = hash_array.merge(YAML.load_file(@@hash_path))
      else
        @@logmap = hash_array
        @@hashmap = hash_array
      end
    end

    # called when running the unit tests
    # create a new folder for testing
    def RevLog.setup_tester(root = Dir.pwd)
      @@cop_path = File.join(root, '.cn')
      @@rev_path = File.join(@@cop_path, 'revs')
      @@log_path = File.join(@@cop_path, 'logmap')
      @@hash_path = File.join(@@cop_path, 'hashmap')
      Dir.mkdir(@@cop_path) unless Dir.exist?(@@cop_path)
      Dir.mkdir(@@rev_path) unless Dir.exist?(@@rev_path)
      if File.exist?(@@log_path) && File.exist?(@@hash_path)
        @@logmap = hash_array.merge(YAML.load_file(@@log_path))
        @@hashmap = hash_array.merge(YAML.load_file(@@hash_path))
      else
        @@logmap = hash_array
        @@hashmap = hash_array
      end
    end

    def hash_array
      Hash.new {[]}
    end

    def RevLog.add_file(file_name, content)
      hash = hash_file(file_name, content)
      File.open(File.join(@@rev_path, hash), 'w') { |f| f.write(content) }
      @@logmap[file_name] = @@logmap[file_name] << {:time => Time.now,
                                                    :hash => hash}
      @@hashmap[hash] = @@hashmap[hash] << {:time => Time.now,
                                            :filename => file_name}
      updatelog
      return hash
    end

    ## return 1 if succeed, otherwise 0
    def RevLog.delete_file(file_id)
      begin
        file_name = @@hashmap[file_id][0][:filename]
        @@hashmap[file_id].delete_if { |e| e[:filename] == file_name }
        @@logmap[file_name].delete_if { |e| e[:hash] == file_id }
        updatelog
        File.delete(File.join(@@rev_path, file_id))
        return 1
      rescue Exception
        return 0
      end
    end


    def RevLog.get_file(id)
      file_path = File.join(@@rev_path, id.to_s)
      if File.exist? file_path
        File.open(file_path, 'r') { |f| return f.read }
      else
        raise Exception, 'RevLog: invalid file revision id!'.red
      end
    end


    def RevLog.diff_files(file_id1, file_id2)
      Diffy::Diff.new(get_file(file_id1), get_file(file_id2)).to_s()
    end

    def RevLog.hash_file(file_name, content)
      Digest::SHA256.hexdigest(file_name + content.to_s)
    end

    def RevLog.merge(id1, id2)
      diff_a = Diffy::Diff.new(get_file(id1), get_file(id2)).each_chunk.to_a
      return get_file(id2) if diff_a.all? { |d| d[0]!='-'}
      # return get_file(id1) if diff_a.all? { |d| d[0]!='+'}
      diff_a
    end

    def RevLog.history(file_name)
      hashs = []
      @@logmap[file_name].each { |m| hashs << m[:hash] }
      hashs
    end

    def RevLog.updatelog
      File.open(@@log_path, 'w') { |f| f.write(@@logmap.to_yaml) }
      File.open(@@hash_path, 'w') { |f| f.write(@@hashmap.to_yaml) }
    end
  end
end
