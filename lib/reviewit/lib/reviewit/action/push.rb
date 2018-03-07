module Reviewit
  class Push < Action
    def run
      check_dirty_working_copy!

      run_linter! if options[:linter]
      url = nil
      mr_id = mr_id_from_head

      if mr_id
        puts 'Updating merge request...'
        url = update_merge_request(mr_id)
        puts "Merge Request updated at #{url}"
      else
        abort 'You need to specify the target branch before creating a merge request.' if options[:branch].nil?
        puts 'Creating merge request...'
        url = create_merge_request
        puts "Merge Request created at #{url}"
      end
      copy_to_clipboard(url)
    end

    private

    def parse_options
      options = Trollop.options do
        opt :message, 'A message to the given action', type: String
        opt :linter, 'Run linter', default: true
        opt :rename, 'Rename branch after push.', default: true
        opt :'allow-dirty', 'Allow push even if your working copy is dirty.', default: false
        opt :ci, 'Push code to CI.', default: true
      end
      options[:branch] = ARGV.shift
      options
    end

    def update_merge_request(mr_id)
      description = (options[:message] or read_user_single_line_message('Type a single line description of the change: '))
      api.update_merge_request(mr_id, diff: commit_diff,
                                      description: description,
                                      target_branch: options[:branch],
                                      linter_ok: linter_ok?,
                                      ci: should_run_ci?)
    end

    def create_merge_request
      mr = api.create_merge_request(diff: commit_diff,
                                    target_branch: options[:branch],
                                    linter_ok: linter_ok?,
                                    ci: should_run_ci?)
      append_mr_id_to_commit(mr[:id])
      rename_local_branch(mr[:id]) if options[:rename]
      mr[:url]
    end

    def commit_diff
      @commit_diff ||= generate_commit_diff
    end

    def generate_commit_diff
      diff = `git format-patch --stdout --no-stat -M HEAD~1`
      diff.sub!(/^Subject: \[PATCH\]/, 'Subject:')
      diff.sub!(/^#{MR_STAMP} \d+\n\n/m, '')
      diff
    end

    def append_mr_id_to_commit(mr_id)
      open('|git commit --amend -F -', 'w+') do |git|
        git.write(commit_message)
        git.write("\n\n#{MR_STAMP} #{mr_id}\n")
        git.close
      end
    end

    def rename_local_branch(mr_id)
      branch = `git symbolic-ref -q HEAD`.gsub('refs/heads/', '').strip
      new_name = "mr-#{mr_id}-#{branch}"

      system("git branch -m #{new_name}") or raise 'Branch rename failed'
      puts "Local branch renamed to #{new_name}. Use --no-rename to avoid this."
      new_name
    end

    def linter_ok?
      @linter_ok ||= false
    end

    def should_run_ci?
      options[:ci]
    end

    def changed_files
      matches = `git show --format=short`.scan(/^--- (.*)\n\+\+\+ (.*)$/)
      matches.reject! do |pair|
        pair[1] == '/dev/null'
      end
      matches.map do |pair|
        File.join(root_dir, pair[1][2..-1])
      end
    end

    def run_linter!
      if linter.empty?
        puts 'No linter configured.'
        return
      end

      linter_command = "./#{linter} #{changed_files.join(' ')}"
      puts linter_command

      Dir.chdir(root_dir) do
        @linter_ok = system(linter_command)
      end
      raise 'Lint error' unless @linter_ok
    end
  end
end
