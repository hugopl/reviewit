module Reviewit
  class Cancel < Action
    def run
      mr_id = options[:mr]
      mr_id ||= mr_id_from_head
      raise 'There are no merge request on HEAD and you didn\'t specified one.' if mr_id.nil?

      mr = api.merge_request(mr_id)

      puts "Abandon MR #{WHITE}“#{mr['subject']}”#{NO_COLOR} (yn)?"
      return unless STDIN.gets.downcase.start_with?('y')

      api.abandon_merge_request(mr_id)
      puts 'Merge request abandoned.'
    end

    def self.parse_options
      Optimist.options
      mr = ARGV.shift
      { mr: mr }
    end
  end
end
