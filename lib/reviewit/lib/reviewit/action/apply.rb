module Reviewit
  class Apply < Action
    def run
      check_dirty_working_copy!

      patches = options[:mr].map { |mr| api.merge_request(mr) }

      fetch_repository if options[:fetch]

      if options[:branch]
        first_patch = patches.first # First patch decides the branch
        new_branch = branch_name_for(options[:mr].first, first_patch['subject'])
        if branch_exists?(new_branch)
          puts "A branch named #{WHITE}“#{new_branch}”#{NO_COLOR} already exists, REMOVE it? (yn)?"
          if STDIN.gets.downcase.start_with?('y')
            remove_branch(new_branch)
          else
            puts 'So rename the branch and try again.'
            return
          end
        end
        create_branch(first_patch['target_branch'], new_branch)
      end

      patches.each_with_index do |patch, i|
        file = Tempfile.new("patch_#{i}")
        file.puts(patch['patch'])
        file.close
        ok = system("git am #{file.path}")
        raise "Failed to apply patch, run #{WHITE}git am --abort#{NO_COLOR} to be cool." unless ok
      end
    end

    private

    include GitUtil

    def branch_name_for(mr, patch)
      "mr-#{mr}-#{patch.downcase}"
    end

    def parse_options
      options = Trollop.options do
        opt :branch, 'Create a branch, then apply the patch', default: true
        opt :fetch, 'Fetch repository before apply the branch', default: true
      end
      options[:mr] = ARGV
      raise 'You need to inform the merge request id' if options[:mr].nil?
      options
    end
  end
end
