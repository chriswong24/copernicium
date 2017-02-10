Gem::Specification.new do |g|
  g.name        = 'copernicium'
  g.version     = '0.3'
  g.date        = '2015-12-12'
  g.summary     = 'Simple DVCS in Ruby.'
  g.description = 'A simple distributed version control system written in Ruby.'
  g.homepage    = 'http://github.com/jeremywrnr/copernicium'
  g.author      = 'Team Copernicium (cn)'
  g.email       = 'jeremywrnr@gmail.com'
  g.license     = 'MIT'
  g.executables = ['cn']
  g.files       = ['lib/pushpull.rb',
                   'lib/repos.rb',
                   'lib/RevLog.rb',
                   'lib/banners.rb',
                   'lib/required.rb',
                   'lib/workspace.rb',
                   'lib/ui.rb']

  # BUNLDER DEPENDENCIES
  g.add_dependency 'diffy'
  g.add_dependency 'net-scp'
  g.add_dependency 'net-ssh'
  g.add_development_dependency 'minitest'
  g.add_development_dependency 'minitest-reporters'
  g.add_development_dependency 'byebug'
  g.add_development_dependency 'rdoc'
  g.add_development_dependency 'rake'
end
