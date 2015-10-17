require 'minitest/spec'
require 'minitest/autorun'
require_relative 'RevLog'

class TestMyRevLogModule < Minitest::Test

  describe "RevLogModule" do
    before "manipulating the log" do
      @db = RevLog.new
      @fileRef = @db.addFile(RevLog.dummyFileObject, nil)
    end
    # addFile(fileObject, fileReferenceString)
    # -> (fileReferenceString, versionReferenceString)
    # "add the file corresponding to the fileReferenceString to database, if
    # the fileReferenceString is empty, then create new entry in the
    # database"
    it "can add a file" do
      @db.addFile(RevLog.dummyFileObject, nil)
      @db.length.must_equal 2
    end
    # alterFile(fileObject, fileReferenceString, versionReferenceString)
    # -> True if succeed, otherwise False
    it "can alter a file" do
      @db.alterFile(RevLog.dummyFileObject, 
                    @fileRef[0],
                    @fileRef[1]).wont_be nil
    end
    # deleteFileVersion(fileReferenceString, versionReferenceString)
    # -> True if succeed, otherwise False

    it "can delete a version" do
      @db.deleteFileVersion(@fileRef[0],
                            @fileRef[1]).must_equal true
    end

    # deleteFile(fileReferenceString)
    # -> True if succeed, otherwise False

    it "can delete a file" do
      @db.deleteFile(@fileRef[0]).must_equal true
    end

    # viewFileHistory(fileReferenceString)
    # -> A map whose values are versionReferenceString

    it "can view the log of a file" do
      @db.viewFileHistory(@fileRef[0]).is_a?(Hash).must_equal true
    end
    
    # diffFile(fileReferenceString1, fileReferenceString2,
    #          versionReferenceString1, versionReferenceString2)
    # -> Text describing the difference of two files
    it "can view the difference" do
      fileRef2 = @db.addFile(RevLog.dummyFileObject, nil)
      @db.diffFile(@fileRef[0],
                   fileRef2[0],
                   @fileRef[1],
                   fileRef2[1]).is_a?(String).must_equal true
    end


    # getFile(fileReferenceString, versionReferenceString)
    # -> fileObject
    

    it "can get a file" do
      @db.getFile(@fileRef[0],
                  @fileRef[1]).is_a?(RevLog.FileObject).must_equal true
    end

  end
end
