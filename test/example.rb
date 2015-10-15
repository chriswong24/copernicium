require 'minitest/spec'
require 'minitest/autorun'

# An example module test that documents the interactions between
# the UI module and the Push & Pull module
class TestMyPushPullModule < Minitest::Test

  describe "PushPullModule" do
    before "create communication object sent by the UI module" do

      comm = UICommunicationObject.new

    end

    it "can read a push command from the UI module" do
      # do push stuff
    end

    it "can read a pull command from the UI module" do
      # do pull stuff
    end

  end
end

# An oversimplified communication object that will be passed between
# modules, containing the data needed to connect the modules.
class UICommunicationObject

  attr_reader :commands

  def initialize
    commands = ['push', 'remote', 'branch']
  end

end
