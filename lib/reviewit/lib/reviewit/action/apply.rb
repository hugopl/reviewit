module Reviewit
  class Apply < Action
    def run
      patch = api.merge_request(options[:mr])

      fetch_repository if options[:fetch]
      create_branch(patch['target_branch'],
                    "mr-#{options[:mr]}-#{patch['subject'].downcase.gsub(/\s/, '_')}") if options[:branch]

      file = Tempfile.new 'patch'
      file.puts patch['patch']
      file.close

      ok = system("git am #{file.path}")
      raise "Failed to apply patch, run #{WHITE}git am --abort#{NO_COLOR} to be cool." unless ok
    end

    private

    include GitUtil

    def parse_options
      options = Trollop.options do
        opt :branch, 'Create a branch, then apply the patch', default: true
        opt :fetch, 'Fetch repository before apply the branch', default: true
      end
      options[:mr] = ARGV.shift
      raise 'You need to inform the merge request id' if options[:mr].nil?
      options
    end
  end
end
