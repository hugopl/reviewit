module Reviewit
  class Cancel < Action

    def run
      @mr_id = options[:mr]
      if @mr_id.nil?
        read_commit_header
        process_commit_message!
        raise 'There are no merge request on HEAD and you didn\'t specified one.' if @mr_id.nil?
      end

      api.abandon_merge_request @mr_id
      puts 'Merge request abandoned.'
    end

    private

    def parse_options
      options = Trollop::options {}
      mr = ARGV.shift
      { mr: mr }
    end
  end
end
