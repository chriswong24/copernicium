# Frank Tamburrino
# CSC 253
# Unit Tests for Push and Pull
# October 15, 2015

require 'test_helper'

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

  def test_store_comms	# test uploading comms to the module
    @inst.load(@push_com)
    assert_equal [@inst.com, @inst.remote, @inst.remote], ['push', '127.0.0.1', 'master']

    @isnt.load(@pull_com)
    assert_equal [@inst.com, @inst.remote, @inst.remote], ['pull', '127.0.0.1', 'master']
  end

  def test_connect	# test for a good connection and a bad connection
    @inst.load(@push_com)
    conn = @inst.test_conn
    assert_equal conn, true

    @inst.load(@bad_com)
    conn = @inst.test_conn
    assert_equal conn, false
  end

  def test_push
    @inst.load(@push_com)
    result = @inst.exe
    assert_equal result, "Successful push, branch #{push_comm.commands[2]} updated\n"
  end

  def test_pull
    @inst.load(@pull_com)
    result = @inst.exe
    assert_equal result, "Successful pull, branch #{pull_comm.commands[2]} updated\n"
  end

  def test_clone
    @inst.load(@clone_com)
    result = @inst.exe
    assert_equal result, "Successful clone, local repository created!\n"
  end
end

# Placeholder for real comms object
class UICommunicationObject

  attr_reader :commands

  def initialize(pull, addr, branch)
    commands = [pull, addr, branch]
  end
end
