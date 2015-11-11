require_relative 'test_helper'


# test cases for clean() functions
# This function delete all the files in the workspace and create a empty workspace
# The test cases will check if the workspace is empty after calling the clean function

class TestWorkspace < MiniTest::Unit::TestCase
  def setup
    @workspace = workspace.new
  end

  def test_clean1()
    @workspace.clean
    isEmpty = Dir[@workspace.dir].empty?
    assert_equal true, isEmpty  #, 'The clean is not working correctly'
  end

  def test_clean2()
    FileUtils.rm_rf(dirname)
    @workspace.clean
    isEmpty = Dir[@workspace.dir].empty?
    assert_equal true, isEmpty #, 'The clean is not working correctly')
  end



  # test cases for display() function
  # This function dispalys all the files in the workspace
  # This test case will check if an empty workspce is displaced correctly. It will also if the workspace will be displaced correctly after adding several files.

  def test_display1()
    @workspace.clean
    @workspace.display
    # check the output of the terminal to see if the output is empty
  end

  def test_display2()
    @workspace.clean
    File.new(@workspace.dir + 'a.txt', 'w')
    File.new(@workspace.dir + 'test/b.txt', 'w')
    @workspace.display
    # check if the outputs are a.txt and test/b.txt
  end



  # test cases for stage(stageType, stageFile) function
  # When called, the stage function will add one item in the staged.txt recording the stage type, stage file path and the time for staged
  # so the test cases checks after add, update, delete if there is a corresponding item in the staged.txt file
  def test_stage1(versionNumber, testFile1, testFile2, testFile3)
    @workspace.clean
    @workspce.checkOutToWorkspace(versionNumber)
    # check if staged.txt is empty by compare with testFile
    identical = FileUtils.compare_file(@workspace.staged, testFile)
    assert_equal true, identical  #, 'The staged.txt is not generated correctly')
  end

  def test_stage2(versionNumber)
    @workspace.clean
    @workspace.checkOutToWorkspace(versionNumber)
    File.new(@workspace.dir + 'a.txt', 'w')
    @workspace.stage('add', 'a.txt')
    # check if there is an add a.txt item in the staged.txt
    @workspace.commitFromWorkspace
    writeSomething(a.txt)
    @workspace.stage('update', 'a.txt')
    #check if there is an update a.txt item in the staged.txt
    @workspace.commitFromWorkspace
    FileUtils.rm('a.txt')
    @workspace.stage('delete', 'a.txt')
    #check if there is a delete a.txt item in the staged.txt
  end

  # test cases for checkOutToWorkspace(versionNumer) function
  # This module get a version object from the repository given a version number. Then from the version object, copy all the files in this version to the workspace. So this test case checks if the workspace contains exactly all the files in the version
  # In this test case, first clean the workspace, and call checkOutToWorkspace. Then get the file list from the version, and check if the files are in the workspace. It also checks if the satged.txt and the version.info are generated correctly

  def test_checkOutToWorkspace(versionNumber, test_stagedFile, test_versionFile)
    @workspace.clean
    @workspace.checkOutToWorkspace(versionNumber)
    version = repository.getVersion(versionNUmber)
    fileList = version.getFileList()

    same = true
    for file in fileList
      exist = File.exist?(@workspace.dir + file)
      same = same && exist
      identical = FileUtils.compare_file(@workspace.dir + file, version.dir + file)
      same = same && identical
    end

    assert_equal true, same #, 'The workspace is different from the checked out version')

    identical = FileUtils.compare_file(@workspace.staged, test_stagedFile)
    assert_equal true, identical #, 'The staged.txt is not generated correctly')

    identical = FileUtils.compare_file(@workspace.version, test_versionFile)
    assert_equal true, identical #, 'The version.info is not generated correctly')
  end



  # test cases for commitFromWorkspace() function
  #This function will return a file list containing all the files need to be in the next version
  # The test case will first add some file in a empty verison, add somefiles, stage and commit to check if the added files are in the next version. If then edit and remove somefile, stage and commit to see if the updated file is in the next version but deleted file is not in the next version.
  def text_commitFromWorkspace(testFile1, testFile2)
    @workspace.checkOutToWorkspace(emptyVersion)
    File.new(@workspace.dir + 'a.txt', 'w')
    File.new(@workspace.dir + 'b.txt', 'w')
    @workspace.stage('add', 'a.txt')
    @workspace.stage('add', 'b.txt')
    fileList = @workspace.commitFromWorkspace()
    #check if a.txt is in the next verion
    identical = FileUtils.compare_file(fileList, testFile1)
    assert_equal true, identical #, 'The staged.txt is not generated correctly')

    writeSomething(a.txt)
    @workspace.stage('update', 'a.txt')
    FileUtils.rm('b.txt')
    @workspace.stage('delete', 'b.txt')
    fileList = @workspace.commitFromWorkspace()
    # check if a.txt is in the next version and b.txt is not in the next version
    identical = FileUtils.compare_file(fileList, testFile2)
    assert_equal true, identical  #, 'The staged.txt is not generated correctly')
  end
end

