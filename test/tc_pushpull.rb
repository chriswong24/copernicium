# Frank Tamburrino
# CSC 253
# Unit Tests for Push and Pull
# October 15, 2015
require 'io/console'    # Needed to hide password at console
require_relative 'test_helper.rb'

class TestPushPullModule < Minitest::Test	
  describe Copernicium_PushPull::PushPull do
    before "initialize the PushPull Module" do
      @inst = Copernicium_PushPull::PushPull.new
    end
    
    it "is able to connect to a remote computer" do	# test for a good connection and a bad connection
      conn = @inst.connect("cycle2.csug.rochester.edu")
      conn.must_equal true
		
      conn = @inst.connect("null@cif.rochester.edu")
      conn.must_equal false
    end

    it "can yield a remote connection to a block" do 
      test = Object.new
      conn = @inst.connect("cycle3.csug.rochester.edu") do |x|
        test = (x.exec!("echo Blocks Working!")).strip;
        puts test
      end
      test.must_equal "Blocks Working!"
    end
	
    it "can move files to remote servers" do
      tfile = File.new("comm_t.copernicium", 'w')
      tfile.close
      test = @inst.transfer("cycle3.csug.rochester.edu", "./comm_t.copernicium", "/u/ftamburr/comm_t.copernicium")
      File.delete("comm_t.copernicium")
      @inst.connect("cycle3.csug.rochester.edu") do |x|
        puts(x.exec!("ls ~/comm_t.copernicium").strip)
        x.exec!("rm ~/comm_t.copernicium")
      end
      test.must_equal true
    end
    
    it "can push changes to a remote server" do
      result = @inst.push(nil)
      result.must_equal "Successful push, branch #{nil} updated\n"
    end
	
    it "can pull changes from a server" do
      result = @inst.pull(nil)
      result.must_equal "Successful pull, branch #{nil} updated\n"
    end
	
    it "can clone a repository from a server" do
      result = @inst.clone(nil)
      result.must_equal "Successful clone, local repository created!\n"
    end
  end
end

# Placeholder for real comms object
