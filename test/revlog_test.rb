require_relative 'RevLog'
require 'test/unit'

class TestRevLog < Test::Unit::TestCase
  def setup
    @db = RevLog.new
    @fileRef = @db.addFile(RevLog.dummyFileObject, nil)
  end

  # addFile(fileObject, fileReferenceString)
  # -> (fileReferenceString, versionReferenceString)
  # "add the file corresponding to the fileReferenceString to database, if
  # the fileReferenceString is empty, then create new entry in the
  # database"
  def test_addFile
    @db.addFile(RevLog.dummyFileObject, nil)
    assert_equal(2, @db.length)
  end
  # alterFile(fileObject, fileReferenceString, versionReferenceString)
  # -> True if succeed, otherwise False
  def test_alterFile
    assert_not_equal(nil,
                     @db.alterFile(RevLog.dummyFileObject, 
                                   @fileRef[0],
                                   @fileRef[1]))
  end

  # deleteFileVersion(fileReferenceString, versionReferenceString)
  # -> True if succeed, otherwise False

  def test_deleteFileVersion
    assert_equal(true, 
                 @db.deleteFileVersion(@fileRef[0],
                                       @fileRef[1]))
  end

  # deleteFile(fileReferenceString)
  # -> True if succeed, otherwise False

  def test_deleteFile
    assert_equal(true,
                 @db.deleteFile(@fileRef[0]))
  end

  # viewFileHistory(fileReferenceString)
  # -> A map whose values are versionReferenceString

  def test_viewFileHistory
    assert_equal(true, @db.viewFileHistory(@fileRef[0]).is_a?(Hash))
  end

  # diffFile(fileReferenceString1, fileReferenceString2,
  #          versionReferenceString1, versionReferenceString2)
  # -> Text describing the difference of two files

  def test_diffFile
    fileRef2 = @db.addFile(RevLog.dummyFileObject, nil)
    assert_equal(true, @db.diffFile(@fileRef[0],
                                    fileRef2[0],
                                    @fileRef[1],
                                    fileRef2[1]).is_a?(String))
  end

  # getFile(fileReferenceString, versionReferenceString)
  # -> fileObject
  
  def test_getFile
    assert_equal(true,
                 @db.getFile(@fileRef[0],
                             @fileRef[1]).is_a?(RevLog.FileObject))
  end
end
