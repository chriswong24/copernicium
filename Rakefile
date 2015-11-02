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

# parse how many tests exist/work
task :info do
  puts `rake test 2>/dev/null | sed -ne '/.*tests.*skips/p'`
end

# adding documentation cmds
RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/*.rb")
  #uncomment to show private methods
  #rdoc.options << "--all"
end
