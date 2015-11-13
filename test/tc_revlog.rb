require_relative 'test_helper'
require_relative '../lib/RevLog'

class TestMyRevLogModule < Minitest::Test

  describe "RevLogModule" do
    before "manipulating the log" do
      @db = RevLog::RevLog.new(Dir.pwd)
    end
    
    it "can add a file" do
      hash = @db.add_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end
    # alterFile(fileObject, fileReferenceString, versionReferenceString)
    # -> True if succeed, otherwise False
    it "can alter a file" do
      @db.alterFile(RevLog.DUMMYFILEOBJECT,
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
      fileRef2 = @db.addFile(RevLog.DUMMYFILEOBJECT, nil)
      @db.diffFile(@fileRef[0],
                   fileRef2[0],
                   @fileRef[1],
                   fileRef2[1]).is_a?(String).must_equal true
    end

    it "can get a file" do
      content = @db.get_file(@db.add_file("testfilename1", "testfilecontent1"))
      content.must_equal "testfilecontent1"
    end

    it "can hash a file" do
      hash = @db.hash_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end

    after "RevLogModule" do
      FileUtils.rm_rf(File.join(Dir.pwd, ".cop"))
    end
  end
end
