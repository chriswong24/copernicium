# copernicium revlog unit tests

require_relative 'test_helper'

include Copernicium::RevLog

class TestCoperniciumRevLog < Minitest::Test
  describe "RevLogModule" do
    before "manipulating the log" do
      Copernicium::RevLog.setup
    end

    after "manipulating the log" do
      FileUtils.rm_rf(File.join(Dir.pwd, ".cn"))
    end

    it "can add a file" do
      hash = add_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end

    it "can delete a file" do
      hash = add_file("testfilename", "testfilecontent")
      delete_file(hash).must_equal 1
      delete_file("fakesha").must_equal 0
    end

    it "can view the difference" do
      hash1 = add_file("testfilename", "testfilecontent2")
      hash2 = add_file("testfilename", "testfilecontent1")
      diff_files(hash1, hash2).must_equal "-testfilecontent2\n\\ No newline at end of file\n+testfilecontent1\n\\ No newline at end of file\n"
    end

    it "can merge two files" do
      hash1 = add_file("testfilename", "testfilecontent\ntestfilecontent2\n")
      hash2 = add_file("testfilename", "testfilecontent\n")
      merge(hash2, hash1).must_equal "testfilecontent\ntestfilecontent2\n"
    end

    it "can merge two equal files" do
      hash1 = add_file("testfilename", "testfilecontent\n")
      hash2 = add_file("testfilename", "testfilecontent\n")
      merge(hash2, hash1).must_equal "testfilecontent\n"
    end

    it "can view the history of a file" do
      hash1 = add_file("testfilename", "testfilecontent\ntestfilecontent2\n")
      hash2 = add_file("testfilename", "testfilecontent\n")
      history("testfilename").must_equal([hash1, hash2])
    end

    it "can get a file" do
      content = get_file(add_file("testfilename1", "testfilecontent1"))
      content.must_equal "testfilecontent1"
    end

    it "can hash a file" do
      hash = hash_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end
  end
end

