# workspace module tests

require_relative 'test_helper'

# test cases for clean() functions
# This function delete all the files in the workspace and create a empty
# workspace. The test cases will check if the workspace is empty after calling
# the clean function

class CoperniciumWorkspaceTest < Minitest::Test
  describe 'WorkspaceModule' do
    def runner(string)
      Driver.new.run string.split
    end

    before 'manipulating the workspace' do
      FileUtils.rm_rf('workspace')
      # Dir.mkdir('workspace')
      # Dir.chdir('workspace')
      @workspace = Workspace.new
      @workspace.writeFile('1.txt','1')
      @workspace.writeFile('2.txt', '2')
      commInit = runner('commit -m init commit')
      @workspace.commit(commInit)
    end

    after 'manipulating the workspace' do
      Dir.chdir(File.join(Dir.pwd, '..'))
      FileUtils.rm_rf('workspace')
    end

    it 'can commit a entire workspace' do
      @workspace.writeFile('1.txt','1_1')
      @workspace.writeFile('2.txt','2_2')
      comm = runner('commit -m commit entire workspace')
      @workspace.commit(comm)
      comm = runner('checkout master')
      @workspace.checkout(comm)
      content = @workspace.readFile('1.txt')
      content.must_equal '1_1'
      content = @workspace.readFile('2.txt')
      content.must_equal '2_2'
    end

    it 'can checkout a entire branch' do
      @workspace.writeFile('1.txt', '1_1_1_1')
      @workspace.writeFile('2.txt', '2_2_2_2')
      comm = runner('commit -m commit two files')
      @workspace.commit(comm)
      comm = runner('checkout master')
      @workspace.checkout(comm)

      # todo - actually switch branches

      content = @workspace.readFile('1.txt')
      content.must_equal '1_1_1_1'
      content = @workspace.readFile('2.txt')
      content.must_equal '2_2_2_2'
    end

    it 'can check the status of the workspace' do
      File.delete('2.txt')
      @workspace.writeFile('1.txt', 'edit')
      @workspace.writeFile('3.txt', '3')
      changedFiles = @workspace.status(nil)
      changedFiles.must_equal([['./3.txt'], ['./1.txt'],['./2.txt']])
    end

    it 'can clean the workspace to last commit' do
      @workspace.writeFile('1.txt', '1_1')
      @workspace.writeFile('2.txt', '2_2')
      comm = runner('clean')
      @workspace.clean(comm)
      content = @workspace.readFile('1.txt')
      content.must_equal '1'
      content = @workspace.readFile('2.txt')
      content.must_equal '2'
    end

    it 'can clean specific files in the workspace' do
      @workspace.writeFile('1.txt', '1_1')
      comm = runner('clean 1.txt')
      @workspace.clean(comm)
      content = @workspace.readFile('1.txt')
      content.must_equal '1'
    end

    # will pass after repos.history works
    it 'can commit a list of files' do
      @workspace.writeFile('1.txt', '1_1_1')
      comm = runner('commit 1.txt -m commit one file')
      @workspace.commit(comm)
      comm = runner('checkout master')
      @workspace.checkout(comm)
      content = @workspace.readFile('1.txt')
      content.must_equal '1_1_1'
    end

=begin
    # this feature currently disabled
    it 'can checkout a list of files' do
      @workspace.writeFile('1.txt','none')
      comm = runner('checkout master.txt')
      @workspace.checkout(comm)

      content = @workspace.readFile('1.txt')
      content.must_equal '1'
    end
=end
  end
end

