require 'yaml'

# Revlog Top Level Function Definitions (Xiangru)
# add_file: add a file to the revision history
# in - file name, content
# out - hash id of file (file_id)
# delete_file: a delete a file from revision history
# in - file_id
# out - exit status code
# diff_files: generate the differences between 2 files
# in - two file_ids
# out - list of differences
# get_file: get the contents of a file based on hash id
# in - file_id
# out - content of specified file
# hash_file: generate hash id for a given file
#                               in - file name, content
#                               out - hashed id
#                               merge: given two files, try to merge them
#                               in - file_id_1, file_id_2
#                               out - success and merged file name/content, or failure and conflict

module RevLog
  class RevLog
    def initialize(project_path)
      @project_path = project_path
      @cop_path = File.join(project_path, ".cop")
      @log_path = File.join(@cop_path, "logmap.yaml")
      default_hash = Hash.new {[]}
      if File.exist?(@log_path) then
        @logmap = default_hash.merge(YAML.load_file(@log_path))
      else
        @logmap = default_hash
        unless File.exist?(@cop_path)
          Dir.mkdir(@cop_path)
        end
      end
    end 
    
    def add_file(file_name, content)
      hash = self.hash_file(file_name, content)
      File.open(File.join(@cop_path, hash), "w") { |f|
        f.write(content)
      }
      @logmap[file_name] << {:time => Time.now,
                             :hash => hash}
      update_log_file()
      return hash
    end

    def delete_file(fileReferenceString)
    end
    
    def diff_files(fileReferenceString1, fileReferenceString2,
                   versionReferenceString1, versionReferenceString2)
    end

    def get_file(file_id)
      file_path = File.join(@cop_path, file_id)
      if File.exist?(file_path)
        File.open(file_path, "r") { |f|
          return f.read
        }
      else
        raise Exception, "Invalid file_id!"
      end
    end

    def hash_file(file_name, content)
      Digest::SHA256.hexdigest(file_name + content.to_s)
    end

    def merge(fileObject1, fileObject2)
    end

    # def alterFile(fileObject, fileReferenceString, versionReferenceString)
    # end

    # def deleteFileVersion(fileReferenceString, versionReferenceString)
    # end

    # def viewFileHistory(fileReferenceString)
    # end

  end
end
