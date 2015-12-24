# Logan Gittelson

require_relative "test_helper"

include Copernicium::Repos

class TestCnReposModule < Minitest::Test
  describe "Repos" do
    before "mixin repo module and create file objects" do
      Repos.setup_tester
      @file1 = FileObj.new("file1", [1, 2])
      @file2 = FileObj.new("file2", [3, 4])
      @file3 = FileObj.new("file3", [5, 6])
    end

    after "clean up repo dir" do
      FileUtils.rm_rf(File.join(Dir.pwd, ".cn"))
    end

    describe "Core" do
      it "can create snapshots" do
        Repos.make_snapshot([@file1, @file2]).wont_be_nil
        Repos.history.wont_be_empty
      end

      it "can get a snapshot from an id" do
        @files = [@file1, @file2]
        snapid = Repos.make_snapshot @files
        snap = Repos.get_snapshot snapid
        snap.id.must_equal snapid
        snap.files.must_equal @files
      end

      it "can parse history" do
        snap1 = Repos.make_snapshot [@file1, @file2]
        snap2 = Repos.make_snapshot [@file1, @file2, @file3]
        snap3 = Repos.make_snapshot [@file1, @file3]
        Repos.history.must_equal [snap1, snap2, snap3]
      end

      it "can delete snapshots" do
        snap1 = Repos.make_snapshot [@file1, @file2]
        snap2 = Repos.make_snapshot [@file1, @file2, @file3]
        snap3 = Repos.make_snapshot [@file1, @file3]
        Repos.history.must_equal [snap1, snap2, snap3]
        Repos.delete_snapshot snap1
        Repos.history.must_equal [snap2, snap3]
      end

      it "can diff snapshots that are different" do
        hash1 = RevLog.add_file("test1", "testfilecontent")
        hash2 = RevLog.add_file("test2", "testing testing")
        diff1 = FileObj.new("test1", [hash1])
        diff2 = FileObj.new("test2", [hash2])
        snap1 = Repos.make_snapshot [diff1]
        snap2 = Repos.make_snapshot [diff2]
        Repos.diff_snapshots(snap1, snap1)
        # todo - put in what this should be
      end

      it "can diff snapshots that are equivalent" do
        RevLog.add_file("testfilename", "testfilecontent")
        diff1 = FileObj.new("testfilename", ["dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"])
        diff2 = FileObj.new("testfilename", ["dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"])
        snap1 = Repos.make_snapshot [diff1]
        snap2 = Repos.make_snapshot [diff2]
        Repos.diff_snapshots(snap1, snap1)
        # todo - put in what this should be
      end

      it "can create branches" do
        Repos.make_branch "hello"
        Repos.make_branch "world"
      end

      it "can create and show off branches" do
        tester = ["master", "hello", "world"]
        Repos.make_branch "hello"
        Repos.make_branch "world"
        Repos.branches.must_equal tester
      end

      it "can create branches with different histories" do
        snap1 = Repos.make_snapshot [@file1, @file2]
        snap2 = Repos.make_snapshot [@file1, @file2, @file3]
        snap3 = Repos.make_snapshot [@file1, @file3]
        Repos.make_branch "hello"
        Repos.update_branch "hello"
        snap4 = Repos.make_snapshot [@file2, @file3]
        mast_hist = [snap1, snap2, snap3]
        hell_hist = mast_hist + [snap4]
        Repos.history("master").must_equal mast_hist
        Repos.history("hello").must_equal hell_hist
      end

      it "can switch between branches" do
        @@branch.must_equal "master"
        Repos.make_branch "hello"
        Repos.update_branch "hello"
        @@branch.must_equal "hello"
      end

      it "can delete branchs" do
        tester = ["hello", "world"]
        Repos.make_branch "hello"
        Repos.make_branch "world"
        Repos.delete_branch "master"
        Repos.branches.must_equal tester
      end

      it "can merge branches" do
        @@branch.must_equal "master"
        Repos.make_branch "hello"
        Repos.update_branch "hello"
        @@branch.must_equal "hello"
      end
    end#core

    describe "Merging" do
      def deep_copy(o) Marshal.load(Marshal.dump(o)) end
      before "create histories" do
        Repos.make_snapshot([@file1, @file2])
        Repos.make_snapshot([@file2, @file3])
        @branch = "tester"
        @newer = deep_copy @@history
        @newer[@branch] = deep_copy @@history["master"]
        @newfl = File.join(".cn", "merging_" + @branch)
        @status = {"master"=>"is up-to-date with remote",
                   "tester"=>"created ok"}
      end

      it "can detect equal histories" do
        File.write @newfl, YAML.dump(@newer)
        status = Repos.update(UIComm.new opts: @branch)
        status["master"].must_equal @status["master"]
      end

      it "can merge two histories of a single branch" do
        @newer["master"] << "bump tester"
        File.write @newfl, YAML.dump(@newer)
        status = Repos.update(UIComm.new opts: @branch)
        @@history["master"].must_equal @newer["master"]
        @@history[@branch].must_equal @newer[@branch]
        @@history["master"].length.must_equal 3
        @@history[@branch].length.must_equal 2
        @status["master"] = "updated successfully"
        status.must_equal @status
      end

      it "can merge two branch histories" do
        @newer["master"] << "bump master"
        @newer[@branch] << "bump tester"
        File.write @newfl, YAML.dump(@newer)
        status = Repos.update(UIComm.new opts: @branch)
        @@history["master"].must_equal @newer["master"]
        @@history[@branch].must_equal @newer[@branch]
        @@history["master"].length.must_equal 3
        @@history[@branch].length.must_equal 3
        @status["master"] = "updated successfully"
        status.must_equal @status
      end

      it "can merge two conflicting histories" do
        @newer["master"] = ["other-commit"]
        @newer[@branch] = ["new-commit"]
        File.write @newfl, YAML.dump(@newer)
        status = Repos.update(UIComm.new opts: @branch)
        @@history["master"].length.must_equal 3
        @@history[@branch].length.must_equal 1
        @status["master"] = "merged history with local"
        status.must_equal @status
      end
    end#merge
  end#repos
end

