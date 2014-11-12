module Reviewit
  class Accept < Action

    def run
      api.accept_merge_request options[:mr]
      puts 'Merge request accepted, check later if the integration was successful.'
    end

    private

    def parse_options
      options = Trollop::options {}
      mr = ARGV.shift
      raise 'You need to inform the merge request id' if mr.nil?
      {mr: mr}
    end
  end
end
