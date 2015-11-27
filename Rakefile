require 'rake'
require 'rake/testtask'
require 'rdoc/task'


# default - run travis tests
task :default do system "rake test[travis]" end


# setup development environment with bundler
task :setup do
  system 'gem install bundler'
  system 'bundler install'
end


# run all/module tests
task :test, [:module] do |r, m|
  if m[:module].nil?
    Rake::TestTask.new {|t| t.pattern = "test/tc_*.rb"}

  elsif m[:module] == 'travis'
    # dont run pushpull tests on travis, since they need auth
    Rake::TestTask.new {|t| t.test_files = FileList['test/tc_repos.rb',
    'test/tc_revlog.rb', 'test/tc_ui.rb', 'test/tc_workspace.rb',
    'test/tc_integration.rb']}

  else # run all tests, including pushpull's
    Rake::TestTask.new {|t| t.pattern = "test/tc_#{m[:module]}.rb"}
  end
end


# show repo info
task :info do
  # parse how many tests exist/work
  puts "Copernicium Test info...\n\n"
  puts "All: \t" + `yes | rake test 2>/dev/null | sed -ne '/.*tests.*skips/p'`
  %w[repos revlog ui workspace pushpull].each do |mod|
    puts "#{mod}:\t" +
      `yes | rake test[#{mod}] 2>/dev/null | sed -ne '/.*tests.*skips/p'`
  end

  # list how many commits per branch
  puts "\nCommit info...\n\n"
  def numcommits() `git --no-pager log --oneline | wc -l` end
  def checkout(br) system "git checkout #{br} &>/dev/null" end
  def cleanup(br) numcommits.to_i.to_s + "\t| #{br} commits" end
  original = 'null'
  curnext = false
  `git branch`.split.each do |br|
    puts br
    if curnext
      original = br
      checkout br
      puts cleanup br
      curnext = false
    elsif br != '*'
      checkout br
      puts cleanup br
    else # current branch has a star next to it in `git branch`
      curnext = true
    end
  end

  # return to branch
  checkout original
end


# adding documentation cmds
RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/*.rb")
  rdoc.options << "--all" # show private methods
end

