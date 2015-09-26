module Reviewit
  class Cancel < Action
    def run
      mr_id = options[:mr]
      mr_id ||= mr_id_from_head
      raise 'There are no merge request on HEAD and you didn\'t specified one.' if mr_id.nil?

      api.abandon_merge_request(mr_id)
      puts 'Merge request abandoned.'
    end

    private

    def parse_options
      Trollop.options
      mr = ARGV.shift
      { mr: mr }
    end
  end
end
