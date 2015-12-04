# including coperniciums requirements

require_relative '../lib/required.rb'
include Copernicium

# mute output, overwrite puts
# you can uncomment for debug

def puts(*x) end

# universal place for test requirements

require 'fileutils'              # needed for rm_rf'ing in cleanup
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'

# use for cleaner output
Minitest::Reporters.use!

# use for more verbose
#Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(:color => true)]

