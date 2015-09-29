ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/spec'

Warden.test_mode!
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

module ActiveSupport
  class TestCase
    include FactoryGirl::Syntax::Methods
    include Warden::Test::Helpers
    extend MiniTest::Spec::DSL

    def git_available?
      commit_count = `git rev-list HEAD --count`.to_i
      $?.success? && commit_count >= 342
    end

    def git_diff(hash)
      `git format-patch --stdout --no-stat -M #{hash}~1..#{hash}`
    end
  end
end
