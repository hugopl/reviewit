module Reviewit
  class Cancel < Action

    def run
      read_commit_header
      process_commit_message!

      raise 'There are no merge request on HEAD' if @mr_id.nil?

      api.abandon_merge_request @mr_id
      puts 'Merge request abandoned.'
    end

    private

    def parse_options
      options = Trollop::options do
        opt :all, 'Show all pending MRs including the ones created by me'
      end
      options
    end
  end
end
