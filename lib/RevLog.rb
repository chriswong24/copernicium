module RevLog
  DUMMYFILEOBJECT = File.new("dummyfile.test", 'w+')
  
  class RevLog
    def initialize()
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

    def hash_file(fileObject)
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
