# Frank Tamburrino
# CSC 253
# Unit Tests for Push and Pull
# October 15, 2015

require_relative 'test_helper'

include Copernicium::PushPull

class TestPushPullModule < Minitest::Test
  describe 'Copernicium PushPull' do
    before 'connecting to host, define constants' do
      @remotefile = '/u/jwarn10/testfile'
      @filename = 'testfile'
      File.write(@filename, 'world')
      #@host = 'cycle2.csug.rochester.edu'
      #@user = 'ftamburr'
      #@host = 'cycle3.csug.rochester.edu:/u/jwarn10/testing'
      @host = '/u/jwarn10/testing'
      @user = 'jwarn10'
      @comm = UIComm.new repo: @host, opts: @user, rev: 'master'
      setup = UIComm.new repo: @host, opts: @user,
                         rev: 'master', command: 'test'
      PushPull.UICommandParser setup
    end

    after 'running each test, clean up' do
      File.delete(@filename) if File.exist? @filename
      FileUtils.rm_rf "testing" if Dir.exist? 'testing'
      FileUtils.rm_rf ".cn" if Dir.exist? '.cn'
    end

    it 'can clone a remote cn repo locally' do
      @comm.command = 'clone'
      (PushPull.UICommandParser @comm).must_equal true
       File.read('testing/world').must_equal "hello\n"
    end

    it 'can push to a remote' do
      Workspace.create_project
      @comm.command = 'push'
      (PushPull.UICommandParser @comm).must_equal true
    end

    it 'can pull from a remote' do
      Workspace.create_project
      @comm.command = 'pull'
      (PushPull.UICommandParser @comm).must_equal true
    end

    # test for a good connection and a bad connection
    it 'is able to connect to a remote computer' do
      (PushPull.connect do |ssh|
        ssh.exec!('echo success!')
      end).must_equal true
    end

    it 'can capture output from a block' do
      test = Object.new
      (conn = PushPull.connect do |x|
        test = (x.exec!('echo Blocks Working!')).strip;
      end).must_equal true
      test.must_equal 'Blocks Working!'
    end

    it 'can move files to remote servers for push' do
      (PushPull.transfer do |session|
        session.upload! @filename, @remotefile
      end).must_equal true

      PushPull.connect do |ssh|
        yes = ssh.exec! "test -e '#{@remotefile}' && echo -n exists"
        yes.must_equal "exists"
      end
    end

    it 'can fetch files from a server for pull' do
      File.delete(@filename) if File.exist? @filename
      content = 'hello hello'
      PushPull.connect do |ssh|
        ssh.exec! "rm #{@remotefile}"
        ssh.exec! "echo -n #{content} > #{@remotefile}"
      end

      (PushPull.fetch do |scp|
        scp.download! @remotefile, @filename
      end).must_equal true

      File.read(@filename).must_equal content

      PushPull.connect do |ssh|
        ssh.exec! "rm #{@remotefile}"
      end
    end
  end
end

