# Logan Gittelson

require_relative 'test_helper'

# A preliminary outline for Repos Module unit testing
class TestCnReposModule < Minitest::Test

  describe "ReposModule" do
    before "create objects sent by the other modules" do
      # Populate version with files first
      @my_repo = Repos.new
      @ext_comm # Communication from external module (incoming command)
      #pass

    end

    it "can create snapshot from external command" do
      # do takeSnapshot stuff - need to check docs for proper naming convention
      @my_repo.clear()
      @my_repo.takeSnapshot().wont_be_nil   # takeSnapshot will return success
      @my_repo.manifest.wont_be_empty       # Manifest won't be empty
    end

    it "can restore snapshot from external command" do
      # do restoreSnapshot stuff
      @my_repo.clear()
      @my_repo.takeSnapshot().wont_be_nil
      repo1 = my_repo.current
      # clear/change the workspace
      @my_repo.restoreSnapshot(repo1).wont_be_nil  # returned success
      @my_repo.diffSnapshots(repo1).must_be_nil             # restored correctly
    end

    # UpdateManifest need a test? Only internal?

    it "can read list returned by manifest" do
      # do listManifest stuff
      @my_repo.clear()
      @my_repo.takeSnapshot()
      snap1 = my_repo.current
      @my_repo.takeSnapshot()
      snap2 = my_repo.current
      @my_repo.takeSnapshot()
      snap3 = my_repo.current
      @my_repo.listManifest.must_equal([snap1, snap2, snap3])  # Will probably have to be different than this
    end

    it "can check if snapshot deleted from manifest" do
      # do DeleteSnapshots stuff
      @my_repo.clear()
      @my_repo.takeSnapshot()
      snap1 = @my_repo.current
      @my_repo.takeSnapshot()
      snap2 = @my_repo.current
      @my_repo.takeSnapshot()
      snap3 = @my_repo.current
      @my_repo.deleteSnapshots([snap1])
      @my_repo.listManifest.must_equal([snap2, snap3])  # Will probably have to be different than this
    end

    it "can check if correct differences between snapshots" do
      # do diffSnapshots stuff
      # diffSnapshots will use current if no second parameter specified
      @my_repo.clear()
      @my_repo.takeSnapshot()
      snap1 = @my_repo.current
      # Change workspace
      @my_repo.takeSnapshot()
      snap2 = @my_repo.current
      @my_repo.diffSnapshots(snap1, snap1).must_be_nil
      @my_repo.diffSnapshots(snap1, snap2).wont_be_nil
    end

  end
end

# An oversimplified communication object that will be passed between
# modules, containing the data needed to connect the modules.
class UICommunicationObject

  attr_reader :commands

  def initialize
    commands = ['push', 'remote', 'branch']
  end

end
