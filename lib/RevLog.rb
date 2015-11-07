require 'digest/sha256'
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
  DUMMYFILEOBJECT = File.new("dummyfile.test", 'w+')
  
  class RevLog
    def initialize(project_path)
      @project_path = project_path
      if file.exist?(File.join(project_path,".cop")) then
        @logmap = yaml::load(File.join(project_path, ".cop/logmap.yaml"))
      else
        @logmap = {}
        Dir.mkdir(File.join(project_path, ".cop"))
      end
    end 
    
    def 
    end
 
    def add_file(fileObject, fileReferenceString)
    end

    def delete_file(fileReferenceString)
    end
    
    def diff_files(fileReferenceString1, fileReferenceString2,
                   versionReferenceString1, versionReferenceString2)
    end

    def get_file(fileReferenceString, versionReferenceString)
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


    private
  end
end
