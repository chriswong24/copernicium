# workspace module tests

require_relative 'test_helper'

include Copernicium::Workspace

class CoperniciumWorkspaceTest < Minitest::Test
  describe 'WorkspaceModule' do
    before 'manipulating the workspace' do
      Workspace.setup
      FileUtils.rm_rf('workspace')
      Dir.mkdir('workspace')
      Dir.chdir('workspace')
      writeFile('1.txt', '1')
      writeFile('2.txt', '2')
      Workspace.create_project
      commInit = UIComm.new(command: 'commit',
                            files: ['1.txt', '2.txt'],
                            cmt_msg: message)
      Workspace.commit(commInit)
    end

    after 'manipulating the workspace' do
      Dir.chdir(File.join(Dir.pwd, '..'))
      FileUtils.rm_rf('workspace')
    end

    it 'can commit a entire workspace' do
      writeFile('1.txt','1_1')
      writeFile('2.txt','2_2')
      comm = runner('commit -m commit entire workspace')
      Workspace.commit(comm)
      comm = runner('checkout master')
      checkout(comm)
      content = readFile('1.txt')
      content.must_equal '1_1'
      content = readFile('2.txt')
      content.must_equal '2_2'
    end

    it 'can checkout a entire branch' do
      writeFile('1.txt', '1_1_1_1')
      writeFile('2.txt', '2_2_2_2')
      comm = runner('commit -m commit two files')
      commit(comm)
      comm = runner('checkout master')
      checkout(comm)

      # todo - actually switch branches

      content = readFile('1.txt')
      content.must_equal '1_1_1_1'
      content = readFile('2.txt')
      content.must_equal '2_2_2_2'
    end

    it 'can check the status of the workspace' do
      File.delete('2.txt')
      writeFile('1.txt', 'edit')
      writeFile('3.txt', '3')
      changedFiles = status(nil)
      changedFiles.must_equal([['./3.txt'], ['./1.txt'],['./2.txt']])
    end

    it 'can clean the workspace to last commit' do
      writeFile('1.txt', '1_1')
      writeFile('2.txt', '2_2')
      comm = runner('clean')
      clean(comm)
      content = readFile('1.txt')
      content.must_equal '1'
      content = readFile('2.txt')
      content.must_equal '2'
    end

    it 'can clean specific files in the workspace' do
      writeFile('1.txt', '1_1')
      comm = runner('clean 1.txt')
      clean(comm)
      content = readFile('1.txt')
      content.must_equal '1'
    end

    # will pass after repos.history works
    it 'can commit a list of files' do
      writeFile('1.txt', '1_1_1')
      comm = runner('commit 1.txt -m commit one file')
      commit(comm)
      comm = runner('checkout master')
      checkout(comm)
      content = readFile('1.txt')
      content.must_equal '1_1_1'
    end

    # test cases for clean() functions
    # This function delete all the files in the workspace and create a empty
    # workspace. The test cases will check if the workspace is empty after
    # # calling # the clean function

=begin
    # this feature currently disabled
    it 'can checkout a list of files' do
      writeFile('1.txt','none')
      comm = runner('checkout master.txt')
      checkout(comm)

      content = readFile('1.txt')
      content.must_equal '1'
    end
=end
  end
end

