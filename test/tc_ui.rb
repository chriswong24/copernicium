############################################################
# Ethan J. Johnson
# CSC 453: Dynamic Languages and Software Development
# University of Rochester, Fall 2015
#
# DVCS Project - Preliminary unit tests for UI module
# October 15, 2015
############################################################


require_relative 'test_helper'

include Copernicium::Driver

class TestUI < Minitest::Test
  describe "UIModule" do
    def drive(str)
      Driver.run str.split
    end

    before 'testing the driver ui' do
      drive 'cn init'
      @user = 'jwarn10'
      @host = '/u/jwarn10/testing'
    end

    after 'testing the driver ui' do
      FileUtils.rm_rf "testing" if Dir.exist? 'testing'
      FileUtils.rm_rf ".cn" if Dir.exist? '.cn'
    end

    it "supports 'init' command" do
      Driver.run ["init"]
    end

    it "supports 'status' command" do
      Driver.run ["status"]
    end

    it "supports 'history' command" do
      Driver.run ["history"]
    end

    it "supports 'branch' command" do
      drive "branch"
      drive 'branch -c newbranch'
      drive 'branch -r renamedbranch'
      drive 'branch -d renamedbranch'
      drive 'branch -d nonexistentbranch'
      drive 'branch -c branch1'
      drive 'branch -c branch2'
      drive 'branch branch1'
      # Create new branch without -c
      drive 'branch thirdbranch'
    end

    it "supports 'clean' command" do
      Driver.run ["clean"]
    end

    it "supports 'commit' command" do
      Driver.run %w{commit -m a commit message}
      Driver.run %w{commit -m a \strange commit $message}
    end

    it "supports 'checkout' command" do
      drive 'checkout master'
      drive 'branch -c newbranch'
      drive 'checkout master'
    end

    it "supports 'merge' command" do
      Driver.run %w{commit -m a commit message}
      Driver.run %w{branch -c branch1}
      Driver.run %w{branch -c branch2}
      Driver.run %w{merge branch1}
    end

    it "supports 'clone' command" do
      Driver.run ["clone", @user, @host]
    end

    it "supports 'pull' command" do
       Driver.run ["pull", @user, @host]
    end

    it "supports 'push' command" do
      Driver.run ["push", @user, @host]
    end
  end
end

