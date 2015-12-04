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

# coperncicium files

require_relative "banners"
require_relative "RevLog"
require_relative "repos"
require_relative "pushpull"
require_relative "workspace"
require_relative "ui"

