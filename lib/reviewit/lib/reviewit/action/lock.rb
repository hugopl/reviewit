module Reviewit
  class Lock < Action
    def run
      abort 'You need to specify the branch to be locked.' if options[:branch].nil?
      api.lock_branch(options[:branch])
      puts 'Branch locked!'
    end

    private

    def parse_options
      options = Trollop.options
      options[:branch] = ARGV.shift
      options
    end
  end
end
