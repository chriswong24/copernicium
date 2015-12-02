# open up string class, enable terminal colors
# add some colors, windowing methods

class String
  def colorize(color, mod)
    "\033[#{mod};#{color};49m#{self}\033[0;0m"
  end

  def reset() colorize(0,0) end
  def blu()  colorize(34,0) end
  def yel()  colorize(33,0) end
  def grn()  colorize(32,0) end
  def red()  colorize(31,0) end
end

# create large constant strings

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

