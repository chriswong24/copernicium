# copernicium revlog unit tests

require_relative 'test_helper'

class TestCoperniciumRevLog < Minitest::Test
  describe "RevLogModule" do
    before "manipulating the log" do
      @db = Copernicium::RevLog.new(Dir.pwd)
    end

    after "manipulating the log" do
      FileUtils.rm_rf(File.join(Dir.pwd, ".cn"))
    end

    it "can add a file" do
      hash = @db.add_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end

    it "can delete a file" do
      hash = @db.add_file("testfilename", "testfilecontent")
      @db.delete_file(hash).must_equal 1
      @db.delete_file("fakesha").must_equal 0
    end

    it "can view the difference" do
      hash1 = @db.add_file("testfilename", "testfilecontent2")
      hash2 = @db.add_file("testfilename", "testfilecontent1")
      @db.diff_files(hash1, hash2).must_equal "-testfilecontent2\n\\ No newline at end of file\n+testfilecontent1\n\\ No newline at end of file\n"
    end

    it "can merge two files" do
      hash1 = @db.add_file("testfilename", "testfilecontent\ntestfilecontent2\n")
      hash2 = @db.add_file("testfilename", "testfilecontent\n")
      @db.merge(hash2, hash1).must_equal "testfilecontent\ntestfilecontent2\n"
    end

    it "can merge two equal files" do
      hash1 = @db.add_file("testfilename", "testfilecontent\n")
      hash2 = @db.add_file("testfilename", "testfilecontent\n")
      @db.merge(hash2, hash1).must_equal "testfilecontent\n"
    end

    it "can view the history of a file" do
      hash1 = @db.add_file("testfilename", "testfilecontent\ntestfilecontent2\n")
      hash2 = @db.add_file("testfilename", "testfilecontent\n")
      @db.history("testfilename").must_equal([hash1, hash2])
    end

    it "can get a file" do
      content = @db.get_file(@db.add_file("testfilename1", "testfilecontent1"))
      content.must_equal "testfilecontent1"
    end

    it "can hash a file" do
      hash = @db.hash_file("testfilename", "testfilecontent")
      hash.must_equal "dc198016e4d7dcace98d5843a3e6fd506c1c790110091e6748a15c79fefc02ca"
    end
  end
end

