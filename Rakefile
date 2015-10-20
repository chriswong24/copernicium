require 'rake'
require 'rake/testtask'
task :default  => :test
task :test, [:module] do |r, m| # run module
  if m[:module].nil?
    Rake::TestTask.new {|t| t.pattern = "test/tc_*.rb"}
  else
    Rake::TestTask.new {|t| t.pattern = "test/tc_#{m[:module]}.rb"}
  end
end
