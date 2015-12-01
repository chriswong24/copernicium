# file for large constant strings


HELP_BANNER = <<-EOS
Copernicium (cn) - simple DVCS

Starting out:
    init - create a new repository
    status - check repo status
    help - show more commands
EOS


COMMAND_BANNER = <<-EOS
#{HELP_BANNER}
Commands:
    clean [files]
    commit [files] -m <message>
    checkout [files] <commit id>
    branch [opt] [branchname]
      -r | rename current branch
      -c | create a new branch
    merge <branch name>
    clone <remote url>
    push [remote name]
    pull [remote name]

Options:
    -v: print version
    -h: show help

Note: [optional] <required>

EOS
