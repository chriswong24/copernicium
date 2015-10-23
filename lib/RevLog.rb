module RevLog
  DUMMYFILEOBJECT = File.new("dummyfile.test", 'w+')
  
  class RevLog
    def initialize()
    end
 
    def addFile(fileObject, fileReferenceString)
    end

    def alterFile(fileObject, fileReferenceString, versionReferenceString)
    end

    def deleteFileVersion(fileReferenceString, versionReferenceString)
    end

    def deleteFile(fileReferenceString)
    end

    def viewFileHistory(fileReferenceString)
    end

    def diffFile(fileReferenceString1, fileReferenceString2,
                 versionReferenceString1, versionReferenceString2)
    end

    def getFile(fileReferenceString, versionReferenceString)
    end
  end
  
end
