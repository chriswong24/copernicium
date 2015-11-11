# Frank Tamburrino
# CSC 253
# Unit Tests for Push and Pull
# October 15, 2015

require_relative 'test_helper'

class TestPushPullModule < Minitest::Test
  @inst	  # The instance to be used for the testing
  @push_com # The command for testing push
  @pull_com # The command for testing pull
  @bad_com  # A bad comms object

  def setup
    @isnt = PushPull.new
    @push_com = UICommunicationObject.new('push', '127.0.0.1', 'master')
    @pulls_com = UICommunicationObject.new('pull', '127.0.0.1', 'master')
    @clone_com = UICommunicationObject.new('clone', '127.0.0.1', 'master')
    @bad_com = UICommunicationObject.new('stasis', '12345', 'no_branch')
  end

  describe PushPull do
    it "stores commands from UI" do	# test uploading comms to the module
      @inst.load(@push_com)
      [@inst.com, @inst.remote, @inst.remote].must_equal ['push', '127.0.0.1', 'master']

      @isnt.load(@pull_com)
      [@inst.com, @inst.remote, @inst.remote].must_equal ['pull', '127.0.0.1', 'master']
    end

    it "is able to connect to a remote computer" do	# test for a good connection and a bad connection
      @inst.load(@push_com)
      conn = @inst.test_conn
      conn.must_equal true

      @inst.load(@bad_com)
      conn = @inst.test_conn
      conn.must_equal false
    end

    it "can push changes to a remote server" do
      @inst.load(@push_com)
      result = @inst.exe
      result.must_equal "Successful push, branch #{push_comm.commands[2]} updated\n"
    end

    it "can pull changes from a server" do
      @inst.load(@pull_com)
      result = @inst.exe
      result.must_equal "Successful pull, branch #{pull_comm.commands[2]} updated\n"
    end

    it "can clone a repository from a server" do
      @inst.load(@clone_com)
      result = @inst.exe
      result.must_equal "Successful clone, local repository created!\n"
    end
  end
end

# Placeholder for real comms object
class UICommunicationObject

  attr_reader :commands

  def initialize(pull, addr, branch)
    commands = [pull, addr, branch]
  end
end
