# workspace module tests

require_relative 'test_helper'

include Copernicium::Workspace

class CoperniciumWorkspaceTest < Minitest::Test
  describe 'WorkspaceModule' do
    before 'manipulating the workspace' do
      Dir.mkdir('workspace')
      Dir.chdir('workspace')
      File.write('1.txt', '1')
      File.write('2.txt', '2')

      Workspace.setup
      Workspace.create_project
      commInit = UIComm.new(files: ['1.txt', '2.txt'])
      Workspace.commit(commInit)
    end

    after 'manipulating the workspace' do
      Dir.chdir(File.join(Dir.pwd, '..'))
      FileUtils.rm_rf('workspace')
    end

    it 'can commit a entire workspace' do
      File.write('1.txt','1_1')
      File.write('2.txt','2_2')
      comm = UIComm.new(command: 'commit', files: ['1.txt', '2.txt'])
      Workspace.commit(comm)

      content = File.read('1.txt')
      content.must_equal '1_1'
      content = File.read('2.txt')
      content.must_equal '2_2'
    end

    it 'can checkout a entire branch' do
      File.write('1.txt', '1_1_1_1')
      File.write('2.txt', '2_2_2_2')
      comm = UIComm.new(command: 'commit', files: ['1.txt', '2.txt'])
      Workspace.commit(comm)
      comm = UIComm.new(rev: 'master')
      Workspace.checkout(comm)

      # todo - actually switch branches

      content = File.read('1.txt')
      content.must_equal '1_1_1_1'
      content = File.read('2.txt')
      content.must_equal '2_2_2_2'
    end

    it 'can check the status of the workspace' do
      File.delete('2.txt')
      File.write('1.txt', 'edit')
      File.write('3.txt', '3')
      changedFiles = Workspace.status
      changedFiles.must_equal([['./3.txt'], ['./1.txt'],['./2.txt']])
    end

    it 'can clean the workspace to last commit' do
      File.write('1.txt', '1_1')
      File.write('2.txt', '2_2')
      comm = UIComm.new(files: ['1.txt', '2.txt'])
      Workspace.clean(comm)
      content = File.read('1.txt')
      content.must_equal '1'
      content = File.read('2.txt')
      content.must_equal '2'
    end

    it 'can clean specific files in the workspace' do
      File.write('1.txt', '1_1')
      comm = UIComm.new(command: 'clean', files: ['1.txt'])
      Workspace.clean(comm)
      content = File.read('1.txt')
      content.must_equal '1'
    end

    # will pass after repos.history works
    it 'can commit a list of files' do
      File.write('1.txt', '1_1_1')
      comm = UIComm.new(command: 'commit', files: ['1.txt'])
      Workspace.commit(comm)
      content = File.read('1.txt')
      content.must_equal '1_1_1'
    end

    # test cases for clean() functions
    # This function delete all the files in the workspace and create a empty
    # workspace. The test cases will check if the workspace is empty after
    # # calling # the clean function

=begin
    # this feature currently disabled
    it 'can checkout a list of files' do
      File.write('1.txt','none')
      comm = runner('checkout master.txt')
      checkout(comm)

      content = File.read('1.txt')
      content.must_equal '1'
    end
=end
  end
end

