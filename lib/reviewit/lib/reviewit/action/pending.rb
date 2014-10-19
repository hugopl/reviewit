module Reviewit
  class Pending < Action

    def run
      list = api.pending_merge_requests
      max_subject = 0
      list.each do |mr|
        len = mr[:subject].length
        max_subject = len if len > max_subject
      end
      list.each do |mr|
        puts "%d  %-#{max_subject}s    %s" % [mr[:id], mr[:subject], mr[:url]]
      end
      puts 'No reviews pending, yay!!' if list.empty?
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
