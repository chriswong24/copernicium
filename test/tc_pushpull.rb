# Frank Tamburrino
# CSC 253
# Unit Tests for Push and Pull
# October 15, 2015

require_relative 'test_helper'

include Copernicium::PushPull

class TestPushPullModule < Minitest::Test
  describe 'Copernicium PushPull' do
    before 'connecting to host, define constants' do
      @filename = 'copernicium'
      File.write(@filename, 'hello')
      #@host = 'cycle2.csug.rochester.edu'
      #@user = 'ftamburr'
      @host = 'cycle3.csug.rochester.edu:/u/jwarn10/testing'
      @user = 'jwarn10'
      @comm = UIComm.new(repo: @host, opts: @user, rev: 'master')
      setup = UIComm.new(repo: @host, opts: @user, rev: 'master')
      setup.command = 'test'
      PushPull.UICommandParser setup
    end

    after 'running each test, clean up' do
      File.delete(@filename) if File.exist? @filename
      FileUtils.rm_rf "testing" if Dir.exist? 'testing'
    end

    it 'can clone a remote cn repo locally' do
      @comm.command = 'clone'
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
        session.upload!(@filename, '/localdisk/' + @filename)
      end).must_equal true

      PushPull.connect do |ssh|
        yes = ssh.exec! "test -e /localdisk/#{@filename} && echo 'exists'"
        yes.must_equal "exists\n"
      end
    end

    it 'can fetch files from a server for pull' do
      PushPull.connect do |ssh|
        ssh.exec! "touch /localdisk/#{@filename}"
      end
      File.delete(@filename) if File.exist? @filename
      (PushPull.fetch do |scp|
        scp.download! "/localdisk/#{@filename}", @filename
        File.read(@filename).must_equal 'hello'
      end).must_equal true
    end
  end
end

