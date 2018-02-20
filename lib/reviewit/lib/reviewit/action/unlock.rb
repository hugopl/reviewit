module Reviewit
  class Unlock < Action
    def run
      abort 'You need to specify the branch to be unlocked.' if options[:branch].nil?
      api.unlock_branch(options[:branch])
      puts 'Branch unlocked!'
    end

    private

    def parse_options
      options = Trollop.options
      options[:branch] = ARGV.shift
      options
    end
  end
end
