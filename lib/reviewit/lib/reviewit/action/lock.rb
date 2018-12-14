module Reviewit
  class Lock < Action
    def run
      abort 'You need to specify the branch to be locked.' if options[:branch].nil?
      abort 'You need to specify the reason. ' if options[:reason].empty?
      api.lock_branch(options[:branch], options[:reason])
      puts 'Branch locked!'
    end

    def self.parse_options
      options = Optimist.options do
        banner  "Usage:\n  review lock [options] BRANCH_NAME REASON\n\nWhere [options] are:"
      end
      options[:branch] = ARGV.shift
      options[:reason] = ARGV.join(' ')
      options
    end
  end
end
