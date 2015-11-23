# relative requirements in lib:

require_relative '../lib/ui.rb'
require_relative '../lib/repos.rb'
require_relative '../lib/RevLog.rb'
require_relative '../lib/pushpull.rb'
require_relative '../lib/workspace.rb'
include Copernicium

# universal place for requirements

require 'fileutils'
require 'io/console'             # Needed to hide password at console
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

