module Reviewit
  class Lock < Action
    def run
      abort 'You need to specify the branch to be locked.' if options[:branch].nil?
      api.lock_branch(options[:branch])
      puts 'Branch locked!'
    end

    def self.parse_options
      options = Optimist.options
      options[:branch] = ARGV.shift
      options
    end
  end
end
