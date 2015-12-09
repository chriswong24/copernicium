Gem::Specification.new do |g|
  g.name        = 'copernicium'
  g.version     = '0.2'
  g.date        = '2015-12-09'
  g.summary     = 'Simple DVCS in Ruby.'
  g.description = 'A simple distributed version control system written in Ruby.'
  g.homepage    = 'http://github.com/jeremywrnr/copernicium'
  g.author      = 'Team Copernicium'
  g.email       = 'jeremywrnr@gmail.com'
  g.license     = 'MIT'
  g.executables = ['cn']
  g.files       = ['lib/pushpull.rb', 'lib/repos.rb', 'lib/RevLog.rb',
                   'lib/banners.rb', 'lib/required.rb',
                   'lib/ui.rb', 'lib/workspace.rb']
  g.add_runtime_dependency 'diffy',                  '~> 3.0', '>= 3.0.7'
  g.add_runtime_dependency 'net-scp',                '~> 1.2', '>= 1.2.1'
  g.add_runtime_dependency 'net-ssh',                '~> 3.0', '>= 3.0.1'
  g.add_development_dependency 'minitest',           '~> 5.8', '>= 5.8.1'
  g.add_development_dependency 'minitest-reporters', '~> 1.1', '>= 1.1.4'
end
