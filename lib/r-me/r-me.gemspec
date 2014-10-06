require './lib/r-me/version.rb'

Gem::Specification.new do |s|
  s.name        = 'r-me'
  s.version     = Rme::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hugo Parente Lima']
  s.email       = ['hugo.pl@gmail.com']
  s.homepage    = 'http://hugopl.github.io/'
  s.summary     = 'R-me command line interface.'
  s.description = 'R-me command line interface, because some times Web interface sux.'
  s.license     = 'MIT'

  s.add_runtime_dependency 'trollop', '~> 2.0'
  s.add_development_dependency 'awesome_print', '~> 1.2'

  s.files         = `git ls-files`.split("\n")
#  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
