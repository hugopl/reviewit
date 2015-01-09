module Reviewit
  class Apply < Action

    def run
      patch = api.merge_request options[:mr]
      file = Tempfile.new 'patch'
      file.puts patch['patch']
      file.close
      ok = system("git am #{file.path}")
      raise 'Failed to apply patch' unless ok
    end

    private

    def parse_options
      Trollop::options {}
      mr = ARGV.shift
      raise 'You need to inform the merge request id' if mr.nil?
      {mr: mr}
    end
  end
end
