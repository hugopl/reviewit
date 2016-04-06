module Reviewit
  class Apply < Action
    def run
      patch = api.merge_request(options[:mr])

      fetch_repository if options[:fetch]

      if options[:branch]
        new_branch = branch_name_for(options[:mr], patch['subject'])
        if branch_exists?(new_branch)
          puts "A branch named #{WHITE}“#{new_branch}”#{NO_COLOR} already exists, REMOVE it? (yn)?"
          if STDIN.gets.downcase.start_with?('y')
            remove_branch(new_branch)
          else
            puts 'So rename the branch and try again.'
            return
          end
        end
        create_branch(patch['target_branch'], new_branch)
      end

      file = Tempfile.new 'patch'
      file.puts patch['patch']
      file.close

      ok = system("git am #{file.path}")
      raise "Failed to apply patch, run #{WHITE}git am --abort#{NO_COLOR} to be cool." unless ok
    end

    private

    include GitUtil

    def branch_name_for(mr, patch)
      git_safe_name("mr-#{mr}-#{patch.downcase}")
    end

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
