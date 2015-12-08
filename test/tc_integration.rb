# integration tests for copernicium modules

## TESTS NEEDED:
#  - Commit
#  - Checkout
#  - Making/Deleting Branches
#  - Merging
#  - Status
#  - Push

require_relative 'test_helper'

include Copernicium::Driver

class CoperniciumIntegrationTests < Minitest::Test
  describe 'IntegrationTesting' do
    def drive(string)
      Driver.run string.split
    end

    before 'create a cn new repo to test' do
      Dir.mkdir('workspace')
      File.write('workspace/1.txt', '1')
      File.write('workspace/2.txt', '2')
      drive 'commit -m Test Commit'
      drive 'branch -c dev'
      Workspace.create_project
      Workspace.setup
    end

    after 'delete the cn repo and the workspace' do
      FileUtils.rm_rf('workspace')
      FileUtils.rm_rf('.cn')
    end

    it 'can commit changes' do
      Repos.history('master').size.must_equal 1
      File.write 'workspace/1.txt', '1_1'
      File.write 'workspace/2.txt', '2_2'
      drive 'commit -m Test Commit'
      Repos.history('master').size.must_equal 2

      #todo : make sure commit written to disk
    end

    it 'can make and delete a branch' do
      drive 'branch test'
      Repos.history('test').wont_be_nil

      drive 'branch -d test'
      Repos.history('test').must_be_nil

      # todo read .cn/branch, verify
    end

=begin
    # Won't work because clean not handled by UI yet
    it 'can revert back to the last commit' do
      File.write('workspace/1.txt', '1_1')
      File.write('workspace/2.txt', '2_2')

      comm = drive('clean')
      Workspace.clean(comm)

      content = File.read('workspace/1.txt')
      content.must_equal '1'
      content = File.read('workspace/2.txt')
      content.must_equal '2'
    end

    # Won't work because clean not handled by UI yet
    it 'can clean specific files in the workspace' do
      File.write('workspace/1.txt', '1_1')
      File.write('workspace/2.txt', '2_2')

      comm = drive('clean workspace/1.txt')
      Workspace.clean(comm)

      Workspace.File.read('workspace/1.txt').must_equal '1'
      Workspace.File.read('workspace/2.txt').must_equal '2_2'
    end

    it 'can check the status of the repository' do
      File.delete('workspace/2.txt')
      @ws.File.write('workspace/1.txt','edit')
      @ws.File.write('workspace/3.txt','3')

      comm = drive('status')
      changedFiles = @ws.status(comm)
      changedFiles.must_equal([['workspace/3.txt'],['workspace/1.txt'],['workspace/2.txt']])
    end

    it 'can checkout a branch' do
      @ws.File.read('workspace/1.txt').must_equal '1'
      @ws.File.read('workspace/2.txt').must_equal '2'
      @ws.File.write('workspace/1.txt', '1_1')
      @ws.File.write('workspace/2.txt', '2_2')
      comm = drive('commit -m Test Commit')
      @ws.commit(comm)

      # Will work once checkout is completed
      comm = drive('checkout dev')
      @ws.checkout(comm)

      # Switch to dev, files should not be modified
      @ws.File.read('workspace/1.txt').must_equal '1'
      @ws.File.read('workspace/2.txt').must_equal '2'

    end

    it 'can checkout a list of files' do
      @ws.File.write('workspace/1.txt','none')
      comm = drive('checkout master ./workspace/1.txt')
      @ws.checkout(comm)

      content = @ws.File.read('workspace/1.txt')
      content.must_equal '1'
    end

    ## Will flesh out merge, push, and pull once they
    # are fleshed out

    it 'can merge two branches' do
      # Assuming currently on master branch, merge dev
      # make sure things work or something.
      comm = drive('merge dev')
      #@pushpull.UICommandParser(comm)
    end

    it 'can push a branch' do
      #push branchname
      comm = drive('push dev')
    end

    it 'can pull a branch' do
      #pull branchname
      comm = drive('pull origin dev')
    end
=end
  end
end

