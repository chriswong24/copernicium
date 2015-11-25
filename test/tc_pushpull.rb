# Frank Tamburrino
# CSC 253
# Unit Tests for Push and Pull
# October 15, 2015
require 'io/console'    # Needed to hide password at console
require_relative 'test_helper.rb'

class TestPushPullModule < Minitest::Test
  describe Copernicium::PushPull do
    before "initialize the PushPull Module" do
      @inst = Copernicium::PushPull.new
    end

    it "is able to connect to a remote computer" do	# test for a good connection and a bad connection
      conn = @inst.connect("cycle2.csug.rochester.edu", @user, @passwd)
      conn.must_equal true

      conn = @inst.connect("null@cif.rochester.edu", @user, @passwd)
      conn.must_equal false
    end

    it "can yield a remote connection to a block" do
      test = Object.new
      conn = @inst.connect("cycle2.csug.rochester.edu", @user, @passwd) do |x|
        test = (x.exec!("echo Blocks Working!")).strip;
      end
      test.must_equal "Blocks Working!"
    end

    it "can move files to remote servers for push" do
      tfile = File.new("comm_t.copernicium", 'w')
      tfile.close
      test = @inst.transfer("cycle2.csug.rochester.edu", "./comm_t.copernicium", "/localdisk/comm_t.copernicium", @user, @passwd)
      File.delete("comm_t.copernicium")
      @inst.connect("cycle2.csug.rochester.edu", @user, @passwd) do |x|
        x.exec!("ls /localdisk/comm_t.copernicium")
        x.exec!("rm /localdisk/comm_t.copernicium")
      end
      test.must_equal true
    end

    it "can fetch files from a server for pull" do
      @inst.connect("cycle2.csug.rochester.edu", @user, @passwd) do |x|
        x.exec!("touch /localdisk/comm_t.copernicium")
      end
      result = @inst.fetch("cycle2.csug.rochester.edu", "/localdisk/comm_t.copernicium", "./", @user, @passwd)
      File.delete("./comm_t.copernicium")
      result.must_equal true
    end

    it "can clone a repository from a server" do
      conn = @inst.connect("cycle2.csug.rochester.edu", @user, @passwd) do |x|
        x.exec!("mkdir /localdisk/.t_copernicium")
        x.exec!("touch /localdisk/.t_copernicium/comm_t.copernicium");
      end
      result = @inst.clone("cycle2.csug.rochester.edu", "/localdisk/.t_copernicium", @user, @passwd)
      conn = @inst.connect("cycle2.csug.rochester.edu", @user, @passwd) do |x|
        x.exec!("rm -r .t_copernicium")
      end
      result.must_equal true
    end
  end
end

