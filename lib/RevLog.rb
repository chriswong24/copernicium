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
  # pushed outside of class so repos can also use
  def hash_array
    Hash.new {[]}
  end

  class RevLog
    def initialize(root)
      @root = root
      @cop_path = File.join(root, '.cn')
      @log_path = File.join(@cop_path, 'logmap.yaml')
      @hash_path = File.join(@cop_path, 'hashmap.yaml')
      if File.exist?(@log_path) && File.exist?(@hash_path)
        @logmap = hash_array.merge(YAML.load_file(@log_path))
        @hashmap = hash_array.merge(YAML.load_file(@hash_path))
      else
        @logmap = hash_array
        @hashmap = hash_array
        Dir.mkdir(@cop_path) unless File.exist?(@cop_path)
      end
    end

    def add_file(file_name, content)
      hash = hash_file(file_name, content)
      File.open(File.join(@cop_path, hash), 'w') { |f|
        f.write(content)
      }
      @logmap[file_name] = @logmap[file_name] << {:time => Time.now,
                                                  :hash => hash}
      @hashmap[hash] = @hashmap[hash] << {:time => Time.now,
                                          :filename => file_name}
      update_log_file()
      return hash
    end

    ## return 1 if succeed, otherwise 0
    def delete_file(file_id)
      begin
        file_name = @hashmap[file_id][0][:filename]
        @hashmap[file_id].delete_if { |e|
          e[:filename] == file_name
        }
        @logmap[file_name].delete_if { |e|
          e[:hash] == file_id
        }
        update_log_file()
        File.delete(File.join(@cop_path, file_id))
        return 1
      rescue Exception
        return 0
      end
    end


    def get_file(id)
      file_path = File.join(@cop_path, id)
      if File.exist? file_path
        File.open(file_path, 'r') { |f| return f.read }
      else
        raise Exception, 'Invalid id!'
      end
    end


    def diff_files(file_id1, file_id2)
      return Diffy::Diff.new(get_file(file_id1),
                             get_file(file_id2)).to_s()
    end

    def hash_file(file_name, content)
      Digest::SHA256.hexdigest(file_name + content.to_s)
    end

    def merge(file_id1, file_id2)
      diff_a = Diffy::Diff.new(get_file(file_id1),
                               get_file(file_id2)).each_chunk.to_a
      return get_file(file_id2) if diff_a.all? { |d| d[0]!='-'}
      # if diff_a.all? { |d| d[0]!='+'}
      #   return get_file(file_id1)
      # end
      diff_a
    end

    def history(file_name)
      hashs = []
      @logmap[file_name].each { |m| hashs << m[:hash] }
      hashs
    end

    def update_log_file
      # writeFile defined in workspace.rb
      writeFile(File.join(@cop_path, 'logmap.yaml'), @logmap.to_yaml)
      writeFile(File.join(@cop_path, 'hashmap.yaml'), @hashmap.to_yaml)
    end

    # def alterFile(fileObject, fileReferenceString, versionReferenceString)
    # end

    # def deleteFileVersion(fileReferenceString, versionReferenceString)
    # end

    # def viewFileHistory(fileReferenceString)
    # end
  end
end
