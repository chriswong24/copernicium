# Logan Gittelson

require_relative 'test_helper'

class TestCnReposModule < Minitest::Test
  describe 'ReposModule' do
    before 'create repo instance' do
      @ws = Workspace.new
      @repo = @ws.repo
    end

    it 'can create snapshots' do
      @repo.make_snapshot(['file1', 'file2']).wont_be_nil
      @repo.manifest.wont_be_empty
    end

    it 'can restore snapshots' do
      snap1 = @repo.make_snapshot(['file1', 'file2'])
      snap1.wont_be_nil
      @repo.restore_snapshot(snap1).wont_be_nil
      @repo.diff_snapshots(snap1).must_be_nil
    end

    it 'can parse history' do
      snap1 = @repo.make_snapshot(['file1', 'file2'])
      snap2 = @repo.make_snapshot(['file1', 'file2', 'file3'])
      snap3 = @repo.make_snapshot(['file1', 'file3'])
      @repo.history().must_equal([snap1, snap2, snap3])
    end

    it 'can check for deleted snapshots' do
      snap1 = @repo.make_snapshot(['file1', 'file2'])
      snap2 = @repo.make_snapshot(['file1', 'file2', 'file3'])
      snap3 = @repo.make_snapshot(['file1', 'file3'])
      @repo.delete_snapshot(snap1)
      @repo.history().must_equal([snap2, snap3])
    end

    it 'can check if correct differences between snapshots' do
      snap1 = @repo.make_snapshot(['file1', 'file2', 'file3'])
      snap2 = @repo.make_snapshot(['file1', 'file3'])
      @repo.diff_snapshots(snap1, snap1).must_equal([])
      @repo.diff_snapshots(snap1, snap2).wont_be_empty
    end

    it 'can create a branch' do
      assert false, 'TODO'
    end

    it 'can switch branches' do
      assert false, 'TODO'
    end
  end
end

