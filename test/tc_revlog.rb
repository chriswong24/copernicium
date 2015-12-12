# copernicium revlog unit tests

require_relative 'test_helper'

include Copernicium::RevLog

class TestCoperniciumRevLog < Minitest::Test
  describe "RevLog" do
    before "manipulating the log, setup tester" do
      Copernicium::RevLog.setup_tester
    end

    after "manipulating the log, remove cn repo" do
      FileUtils.rm_rf(File.join(Dir.pwd, ".cn"))
    end

    it "can add a file" do
      hash = RevLog.add_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end

    it "can delete a file" do
      hash = RevLog.add_file("testfilename", "testfilecontent")
      RevLog.delete_file(hash).must_equal 1
      RevLog.delete_file("fakesha").must_equal 0
    end

    it "can view the difference" do
      hash1 = RevLog.add_file("testfilename", "testfilecontent2")
      hash2 = RevLog.add_file("testfilename", "testfilecontent1")
      RevLog.diff_files(hash1, hash2).must_equal "-testfilecontent2\n\\ No newline at end of file\n+testfilecontent1\n\\ No newline at end of file\n"
    end

    it "can merge two files" do
      hash1 = RevLog.add_file("testfilename", "testfilecontent\ntestfilecontent2\n")
      hash2 = RevLog.add_file("testfilename", "testfilecontent\n")
      RevLog.merge(hash2, hash1).must_equal "testfilecontent\ntestfilecontent2\n"
    end

    it "can merge two equal files" do
      hash1 = RevLog.add_file("testfilename", "testfilecontent\n")
      hash2 = RevLog.add_file("testfilename", "testfilecontent\n")
      RevLog.merge(hash2, hash1).must_equal "testfilecontent\n"
    end

    it "can view the history of a file" do
      hash1 = RevLog.add_file("testfilename", "testfilecontent\ntestfilecontent2\n")
      hash2 = RevLog.add_file("testfilename", "testfilecontent\n")
      RevLog.history("testfilename").must_equal([hash1, hash2])
    end

    it "can get a file" do
      content = RevLog.get_file(RevLog.add_file("testfilename1", "testfilecontent1"))
      content.must_equal "testfilecontent1"
    end

    # todo - this is the same test as add a file...
    it "can hash a file" do
      hash = RevLog.hash_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end
  end
end

