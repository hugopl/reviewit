require "#{File.dirname(__FILE__)}/lib/reviewit/version.rb"

Gem::Specification.new do |s|
  s.name        = 'reviewit'
  s.version     = Reviewit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hugo Parente Lima']
  s.email       = ['hugo.pl@gmail.com']
  s.homepage    = 'https://github.com/hugopl/reviewit'
  s.summary     = 'Review it! is a review tool for git-based projects.'
  s.description = 'Reviewit command line interface, because sometimes Web interface sux.'
  s.license     = 'MIT'

  s.add_runtime_dependency 'trollop', '~> 2.0'
  s.add_development_dependency 'awesome_print', '~> 1.2'

  # FIXME: This can't depend on git.
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
