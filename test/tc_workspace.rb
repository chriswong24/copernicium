require_relative 'test_helper'
require_relative '../lib/workspace'
require 'FileUtils'

# test cases for clean() functions
# This function delete all the files in the workspace and create a empty workspace
# The test cases will check if the workspace is empty after calling the clean function

class TestMyWorspaceModule < Minitest::Test
    describe "WorkspaceModule" do
        before "manipulating the workspace" do
            @workspace = Workspace::Workspace.new(Dir.pwd)
            @workspcae.writeFile("1.txt", "1")
            @workspace.writeFile("2.txt", "2")
            @workspace.commit()
        end

        it "can clean the workspace to last commit" do
            @workspace.writeFile("1.txt","1_1")
            @workspace.writeFile("2.txt", "2_2")
            @workspace.clean()

            content = ""
            File.open("1.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "1"

            content = ""
            File.open("2.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "2"

        end

        it "can clean specific files in the workspace" do
            @workspace.writeFile("1.txt", "1_1")
            @workspace.clean(["1.txt"])

            File.open("1.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end
            content.mush_equal "1"
        end

        it "can commit a entire worksapce" do
	    @workspace.writeFile("1.txt","1_1")
            @workspace.writeFile("2.txt","2_2")
            @workspace.commit()
            @workspace.clean()
            content = ""
            File.open("1.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "1_1"

            content = ""
            File.open("2.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "2_2"
        end

        it "can commit a list of file" do
            @workspace.writeFile("1.txt","1_1_1")
            @workspace.commit(["1.txt"])
            @workspace.clean()
            content = ""
            File.open("1.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "1_1_1"
        end

        it "can checkout a entire branch" do
	    @workspace.writeFile("1.txt","1_1_1_1")
            @workspace.writeFile("2.txt","2_2_2_2")
            @workspace.commit()
            @workspace.checkout('master')
            content = ""
            File.open("1.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "1_1_1_1"

            content = ""
            File.open("2.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "2_2_2_2"
        end

        it "can checkout a list of files" do
	    @workspace.writeFile("1.txt","none")
	    @workspace.checkout('1.txt')
            content = ""
            File.open("1.txt", "r") do |f|
                f.each_line do |line|
                    content = content + line
                end
            end

            content.mush_equal "1_1_1_1"
        end
        
        it "can check the status of the workspace" do
	    FileUtils.rm('2.txt')
	    @workspace.writeFile("1.txt","edit")
	    @workspace.writeFile("3.txt","3")
            changedFiles = @workspace.status()
  	    changedFiles.must_equal([["3.txt"],["1.txt"],["2.txt"]])
        end

    end
end
      
