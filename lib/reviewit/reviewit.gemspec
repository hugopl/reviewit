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

  s.files         = %w(lib/reviewit.rb
                       lib/reviewit/action/accept.rb
                       lib/reviewit/action/action.rb
                       lib/reviewit/action/apply.rb
                       lib/reviewit/action/cancel.rb
                       lib/reviewit/action/cleanup.rb
                       lib/reviewit/action/list.rb
                       lib/reviewit/action/open.rb
                       lib/reviewit/action/push.rb
                       lib/reviewit/action/show.rb
                       lib/reviewit/action/lock.rb
                       lib/reviewit/action/unlock.rb
                       lib/reviewit/api.rb
                       lib/reviewit/app.rb
                       lib/reviewit/git_util.rb
                       lib/reviewit/version.rb)
  s.executables   = %w(review)
  s.require_paths = %w(lib)
end
