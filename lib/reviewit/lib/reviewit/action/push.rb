module Reviewit
  class Push < Action

    def run
      read_commit_header
      read_commit_diff
      process_commit_message!

      if updating?
        puts 'Updating merge request...'
        url = api.update_merge_request(@mr_id, @subject, @commit_message, @commit_diff, read_user_message)
        puts "Merge Request updated at #{url}"
      else
        abort 'You need to specify the target branch before creating a merge request.' if options[:branch].nil?
        puts "Creating merge request..."
        mr = api.create_merge_request(@subject, @commit_message, @commit_diff, options[:branch])
        puts "Merge Request created at #{mr[:url]}"
        append_mr_id_to_commit(mr[:id])
      end
    end

  private

    def parse_options
      options = Trollop::options do
        opt :message, 'A message to the given action', type: String
      end
      options[:branch] = ARGV.shift
      options
    end

    def read_commit_diff
      @commit_diff = `git show --format=""`
    end

    def append_mr_id_to_commit mr_id
      open('|git commit --amend -F -', 'w+') do |git|
        git.write @commit_message
        git.write "\n\n#{MR_STAMP} #{mr_id}\n"
        git.close
      end
    end

    def updating?
      not @mr_id.nil?
    end
  end
end
