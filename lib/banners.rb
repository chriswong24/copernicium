# file for large constant strings


HELP_BANNER = <<-EOS
Copernicium (cn) - simple DVCS

Starting:
    init - create a new repository
    status - check repo status

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

