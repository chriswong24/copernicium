# workspace module tests

require_relative 'test_helper'

include Copernicium::Driver
include Copernicium::Workspace

class CoperniciumWorkspaceTest < Minitest::Test
  describe 'WorkspaceModule' do
    def drive(str) Driver.run str.split end
    before 'manipulating the workspace, make a cn repo' do
      Dir.mkdir('workspace')
      Dir.chdir('workspace')
      File.write('1.txt', '1')
      File.write('2.txt', '2')
      Workspace.create_project
      Workspace.setup # requiring revlog and repos here, cn init
      @init = Workspace.commit(UIComm.new(files: ['1.txt', '2.txt']))
      File.write('1.txt', '1_2')
      File.write('2.txt', '2_1')
      @second = Workspace.commit(UIComm.new(files: ['1.txt', '2.txt']))
    end

    after 'manipulating the workspace, clean cn folder' do
      Dir.chdir(File.join(Dir.pwd, '..'))
      FileUtils.rm_rf('workspace')
    end

    it 'can commit a list of files' do
      File.write('1.txt', '1_1_1')
      Workspace.commit(UIComm.new(files: ['1.txt']))
      File.read('1.txt').must_equal '1_1_1'
    end

    it 'can commit a entire workspace' do
      File.write('1.txt','1_1')
      File.write('2.txt','2_2')
      Workspace.commit
      File.read('1.txt').must_equal '1_1'
      File.read('2.txt').must_equal '2_2'
    end

    it 'can checkout a list of files' do
      File.write('1.txt','none')
      File.write('2.txt','none')
      Workspace.checkout UIComm.new(files: ['1.txt'])
      File.read('1.txt').must_equal '1_2'
      File.read('2.txt').must_equal 'none'
    end

    it 'can checkout a entire branch' do
      drive 'branch new'
      File.write('1.txt', '1_1_1_1')
      File.write('2.txt', '2_2_2_2')
      Workspace.commit
      File.read('1.txt').must_equal '1_1_1_1'
      File.read('2.txt').must_equal '2_2_2_2'
      drive 'branch master'
      Workspace.checkout
      File.read('1.txt').must_equal '1_2'
      File.read('2.txt').must_equal '2_1'
    end

    it 'can checkout a entire branch and switch files' do
      drive 'branch new'
      File.write('1.txt', '1_1_1_1')
      File.write('2.txt', '2_2_2_2')
      drive 'commit -m new'
      File.read('1.txt').must_equal '1_1_1_1'
      File.read('2.txt').must_equal '2_2_2_2'
      drive 'branch master'
      File.read('1.txt').must_equal '1_2'
      File.read('2.txt').must_equal '2_1'
    end

    it 'can check the status of the workspace' do
      File.delete('2.txt')
      File.write('1.txt', 'edit')
      File.write('3.txt', '3')
      Workspace.status.must_equal([['3.txt'], ['1.txt'], ['2.txt']])
    end

    it 'can check the status of the workspace after a commit' do
      File.delete('2.txt')
      Workspace.status.must_equal([[], [], ['2.txt']])
      Workspace.commit
      Workspace.status.must_equal([[], [], []])
    end

    it 'can clean specific files in the workspace' do
      File.write('1.txt', '1_1')
      File.write('2.txt', '222')
      Workspace.clean(UIComm.new(files: ['1.txt']))
      File.read('1.txt').must_equal '1_2'
      File.read('2.txt').must_equal '222'
    end

    it 'can clean the workspace to last commit' do
      File.write('1.txt', 'nil')
      File.write('2.txt', 'nil')
      Workspace.clean
      File.read('1.txt').must_equal '1_2'
      File.read('2.txt').must_equal '2_1'
    end

    it 'can clean the workspace to a specific commit' do
      File.write('1.txt', '1_1')
      File.write('2.txt', '2_2')
      Workspace.clean UIComm.new(rev: @init)
      File.read('1.txt').must_equal '1'
      File.read('2.txt').must_equal '2'
      Workspace.clean UIComm.new(rev: @second)
      File.read('1.txt').must_equal '1_2'
      File.read('2.txt').must_equal '2_1'
    end

    it 'can create files while switching branches' do
      drive 'branch new'
      File.write('3.txt', '3')
      Workspace.commit
      File.delete('3.txt')
      drive 'branch master'
      File.exist?('3.txt').must_equal false
      drive 'branch new'
      File.read('3.txt').must_equal '3'
    end

    it 'can create folders while switching branches' do
      drive 'branch new'
      Dir.mkdir('new')
      File.write('new/3.txt', '3')
      Workspace.commit
      FileUtils.rm_rf('new')
      drive 'branch master'
      Dir.exist?('new').must_equal false
      File.exist?('new/3.txt').must_equal false
      drive 'branch new'
      Dir.exist?('new').must_equal true
      File.read('new/3.txt').must_equal '3'
    end
  end
end

