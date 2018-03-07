module Reviewit
  class Show < Action
    def run
      mr = api.merge_request options[:mr]

      puts "Status: #{mr['status']}"
      puts "Target branch: #{mr['target_branch']}"
      puts "Reviewer: #{mr['reviewer']['name']} <#{mr['reviewer']['email']}>" unless mr['reviewer'].nil?
      print_colored_diff(mr['patch'])
    end

    def self.parse_options
      Trollop.options {}
      mr = ARGV.shift
      raise 'You need to inform the merge request id' if mr.nil?
      { mr: mr }
    end

    private

    def print_colored_diff(diff)
      line_to_end_intersection = 0
      diff.each_line do |line|
        if line.start_with? 'd'
          color = WHITE
          line_to_end_intersection = 4
        elsif line_to_end_intersection.positive?
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
