module Rme
  class Push < Action

    RME_STAMP = "\nRme-URL: "

    def run
      read_commit_header
      read_commit_diff

      if updating?
        api.update_merge_request(@subject, @commit_message, @commit_diff, read_user_message)
      else
        url = api.create_merge_request(@subject, @commit_message, @commit_diff)
        append_url_to_commit(url)
      end
    end
  private
    def read_commit_header
      @subject = `git show -s --format="%s"`.strip
      @commit_message = `git show -s --format="%B"`.strip
    end

    def read_commit_diff
      @commit_diff = `git show --format=""`
    end

    def append_url_to_commit url
      open('|git commit --amend -F -', 'w+') do |git|
        git.write @commit_message
        git.write "\n\nRme-URL: #{url}\n"
        git.close
      end
    end

    def updating?
      @commit_message.include? RME_STAMP
    end
  end
end
