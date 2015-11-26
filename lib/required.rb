# gem requirements

require 'yaml'
require 'diffy'
require 'digest'
require 'pathname'
require 'singleton'
require 'socket'        # Socket needed for communicating over the network
require 'io/console'    # Needed to hide password at console
require 'net/ssh'       # Needed to communicate with the remote
require 'net/scp'       # Needed for file transfer between servers

# gem system files

require_relative "../lib/ui.rb"
require_relative "../lib/repos.rb"
require_relative "../lib/RevLog.rb"
require_relative "../lib/PushPull.rb"
require_relative "../lib/workspace.rb"

