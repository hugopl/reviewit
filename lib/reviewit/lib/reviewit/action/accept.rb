module Reviewit
  class Accept < Action
    def run
      mr_id = options[:mr]
      mr = api.merge_request(mr_id)
      puts "Accept MR #{WHITE}“#{mr['subject']}”#{NO_COLOR} (yn)?"
      return unless STDIN.gets.downcase.start_with?('y')

      api.accept_merge_request(mr_id)
      puts 'Merge request accepted, check later if the integration was successful.'
    end

    private

    def parse_options
      Trollop.options {}
      mr = ARGV.shift
      raise 'You need to inform the merge request id' if mr.nil?
      { mr: mr }
    end
  end
end
