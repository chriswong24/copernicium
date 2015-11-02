require 'rake'
require 'rake/testtask'
require 'rdoc/task'

# run all/module tests
task :default  => :test
task :test, [:module] do |r, m|
  if m[:module].nil?
    Rake::TestTask.new {|t| t.pattern = "test/tc_*.rb"}
  else
    Rake::TestTask.new {|t| t.pattern = "test/tc_#{m[:module]}.rb"}
  end
end

# show info about the repo
task :info do
  # parse how many tests exist/work
  puts "Test info...\n\n"
  puts "All: \t" + `rake test 2>/dev/null | sed -ne '/.*tests.*skips/p'`
  %w[repos revlog ui workspace pushpull].each do |mod|
    puts "#{mod}:\t" + `rake test[#{mod}] 2>/dev/null | sed -ne '/.*tests.*skips/p'`
  end

  # list how many commits per branch
  puts "\nCommit info...\n\n"
  curbr = '---'
  curnext = false
  `git branch`.split.each do |br|
    if curnext
      curbr = br
      `git checkout #{br}`
      puts "#{br} commits: " + `git --no-pager log --oneline | wc -l`
      curnext = false
    elsif br != '*'
      `git checkout #{br}`
      puts "#{br} commits: " + `git --no-pager log --oneline | wc -l`
    else
      curnext = true
    end
  end

  # checkout original branch
  `git checkout #{curbr}`
end

# adding documentation cmds
RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/*.rb")
  #uncomment to show private methods
  #rdoc.options << "--all"
end
