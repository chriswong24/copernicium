# Logan Gittelson

require_relative 'test_helper'

include Copernicium::Repos

# Note on these tests: rather than merely checking that they are not empty
# values, check that they are equal to what you would expect them to be.

class TestCnReposModule < Minitest::Test
  describe 'ReposModule' do
    before 'mixin repo module' do
      Copernicium::Repos.setup
      @file1 = FileObj.new('file1', [1, 2])
      @file2 = FileObj.new('file2', [3, 4])
      @file3 = FileObj.new('file3', [5, 6])
    end

    after "clean up repo dir" do
      FileUtils.rm_rf(File.join(Dir.pwd, ".cn"))
    end

    it 'can create snapshots' do
      make_snapshot([@file1, @file2]).wont_be_nil
      history.wont_be_empty
    end

    it 'can get a snapshot from an id' do
      @files = [@file1, @file2]
      snapid = make_snapshot @files
      snap = get_snapshot snapid
      snap.id.must_equal snapid
      snap.files.must_equal @files
    end

    it 'can parse history' do
      snap1 = make_snapshot [@file1, @file2]
      snap2 = make_snapshot [@file1, @file2, @file3]
      snap3 = make_snapshot [@file1, @file3]
      history.must_equal [snap1, snap2, snap3]
    end

    it 'can delete snapshots' do
      snap1 = make_snapshot [@file1, @file2]
      snap2 = make_snapshot [@file1, @file2, @file3]
      snap3 = make_snapshot [@file1, @file3]
      history.must_equal [snap1, snap2, snap3]
      delete_snapshot snap1
      history.must_equal [snap2, snap3]
    end

    it 'can diff snapshots' do
      snap1 = make_snapshot [@file1, @file2, @file3]
      snap2 = make_snapshot [@file1, @file3]
      diff_snapshots(snap1, snap1) #todo - fix
    end

    it 'can create branches' do
      make_branch 'hello'
      make_branch 'world'
    end

    it 'can create and show off branches' do
      tester = ['master', 'hello', 'world']
      make_branch 'hello'
      make_branch 'world'
      branches.must_equal tester
    end

    it 'can switch between branches' do
      current = @@branch
      current.must_equal 'master'
      make_branch 'hello'
      update_branch 'hello'
      newer = @@branch
      newer.must_equal 'hello'
    end

    it 'can delete branchs' do
      tester = ['hello', 'world']
      make_branch 'hello'
      make_branch 'world'
      delete_branch 'master'
      branches.must_equal tester
    end

    it 'can merge branches' do
      current = @@branch
      current.must_equal 'master'
      make_branch 'hello'
      update_branch 'hello'
      newer = @@branch
      newer.must_equal 'hello'
    end
  end
end

