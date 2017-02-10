require 'rake'
require 'rake/testtask'
require 'rdoc/task'


g='copernicium'
v='0.3'


# setup development environment with bundler
task :setup do
  system 'gem install bundler'
  system 'bundler install'
end


# run all/module tests
task :test, [:module] do |r, m|
  if m[:module].nil? # run all tests, including pushpull's
    Rake::TestTask.new {|t| t.pattern = "test/tc_*.rb"}
  else # just run a specific modules tests
    Rake::TestTask.new {|t| t.pattern = "test/tc_#{m[:module]}.rb"}
  end
end


# travis testing - dont do push pull since ssh needed
# add in later: 'test/tc_integration.rb']}
Rake::TestTask.new do |t|
  t.name = 'travis'
  t.verbose = true
  t.test_files =
    FileList['test/tc_repos.rb', 'test/tc_revlog.rb', 'test/tc_ui.rb',
             'test/tc_workspace.rb', 'test/tc_integration']
end


# default - run travis tests
task :default => :travis


# show repo info
task :info do
  # parse how many tests exist/work
  puts "Copernicium Test info...\n\n"
  puts "All: \t" + `yes | rake test 2>/dev/null | sed -ne '/.*tests.*skips/p'`
  #%w[repos revlog ui workspace integration].each do |mod|
  %w[repos revlog ui workspace pushpull integration].each do |mod|
    puts "#{mod}:\t" +
      `yes | rake test[#{mod}] 2>/dev/null | sed -ne '/.*tests.*skips/p'`
  end

  # list how many commits per branch
  puts "\nBranch Commits...\n\n"
  def numcommits() `git --no-pager log --oneline | wc -l` end
  def checkout(br) system "git checkout #{br} &>/dev/null" end
  def cleanup(br) numcommits.to_i.to_s + " | #{br} commits" end
  original = 'null'
  curnext = false
  `git branch`.split.each do |br| # shows same for each if cant switch branches
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


# imported from makefile
task :build do
  sh "gem build #{g}.gemspec"
  sh "gem install ./#{g}-#{v}.gem"
end

task :clean do
  sh "rm -vf *.gem"
end

task :push => [:clean, :build] do
  sh "gem push #{g}-#{v}.gem"
end

task :dev do
  sh "filewatcher '**/*.rb' 'clear && yes | rake'"
end
