# Logan Gittelson

require 'minitest/spec'
require 'minitest/autorun'

# A preliminary outline for Repos Module unit testing
class TestCnReposModule < Minitest::Test

  describe "ReposModule" do
    before "create objects sent by the other modules" do

      #comm = UICommunicationObject.new
      pass

    end
    
    it "can create snapshot from external command" do
      # do TakeSnapshot stuff
    end

    it "can restore snapshot from external command" do
      # do RestoreSnapshot stuff
    end
    
    # UpdateManifest need a test? Only internal?
    
    it "can read list returned by manifest" do
      # do ListManifest stuff
    end
    
    it "can check if snapshot deleted from manifest" do
      # do DeleteSnapshots stuff
    end
    
    it "can check if correct differences between snapshots" do
      # do DiffSnapshots stuff
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