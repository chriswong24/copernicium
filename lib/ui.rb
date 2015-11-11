# user interface module

module UI
  # Function: parse_command()
  #
  # Parameters:
  #   * cmd - the text command line given by the user
  #
  # Return value:
  #   A UICommandCommunicator object containing details of the command to be
  #   executed by the respective backend module.
  #
  def parse_command(cmd)
    if cmd == "init" or cmd == "status" or cmd == "push" or cmd == "pull"
      return UICommandCommunicator.new(command: cmd)
    end
  end

  # Communication object that will pass commands to backend modules
  class UICommandCommunicator

    attr_reader :command

    # Types of arguments - different fields will be set depending on the command
    attr_reader :files # An array of one or more file paths
    attr_reader :rev # A single revision indicator (commit #, branch name, HEAD, tip, etc.)
    attr_reader :commit_message # A commit message

    def initialize(command: nil, files: nil, rev: nil, commit_message: nil)
      @command = command
      @files = files
      @rev = rev
      @commit_message = commit_message
    end
  end
end
