module Reviewit
  class Show < Action

    def run
      mr = api.merge_request options[:mr]

      puts "Author: #{mr['author']} <#{mr['author_email']}>"
      puts "Status: #{mr['status']}"
      puts "Target branch: #{mr['target_branch']}"
      print_commit_message(mr['commit_message'])
      print_colored_diff(mr['diff'])
    end

    private

    def parse_options
      options = Trollop::options {}
      mr = ARGV.shift
      raise 'You need to inform the merge request id' if mr.nil?
      { mr: mr }
    end

    def print_commit_message message
      puts "\n"
      message.each_line {|line| puts "    #{line}" }
      puts "\n"
    end

    def print_colored_diff diff
      line_to_end_intersection = 0
      diff.each_line do |line|
        if line.start_with? 'd'
          color = WHITE
          line_to_end_intersection = 4
        elsif line_to_end_intersection > 0
          color = WHITE
          line_to_end_intersection -= 1
        elsif line.start_with? '+'
          color = GREEN
        elsif line.start_with? '-'
          color = RED
        elsif line.start_with? '@'
          color = CYAN
        else
          color = ''
        end
        print "#{color}#{line}#{NO_COLOR}"
      end
    end
  end
end
