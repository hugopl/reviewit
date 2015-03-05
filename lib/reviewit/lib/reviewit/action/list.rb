module Reviewit
  class List < Action
    HEADER = %w(Id Status Subject URL)

    def run
      list = api.pending_merge_requests
      if list.empty?
        puts 'No reviews pending, yay!!'
        return
      end

      inject_header(list)
      length = compute_header_lengths(list)

      list.each_with_index do |mr, i|
        puts format("#{row_color(mr, i)}%#{length[:id]}s  %-#{length[:status]}s  %-#{length[:subject]}s  %s#{NO_COLOR}",
                    mr[:id], mr[:status], mr[:subject], mr[:url])
      end
    end

    private

    def parse_options
      options = Trollop.options do
        opt :all, 'Show all pending MRs including the ones created by me'
      end
      options
    end

    def inject_header list
      list.unshift Hash[list.first.keys.map { |k| [k, k.to_s.capitalize] }]
    end

    def row_color mr, i
      case
      when i.zero? then WHITE
      when mr[:ci_status] == 'pass' then GREEN
      when mr[:ci_status] == 'failed' then RED
      end
    end

    def compute_header_lengths list
      length = {}
      list.each do |mr|
        mr.keys.each do |key|
          len = mr[key].to_s.length
          length[key] = len if len > (length[key] or 0)
        end
      end
      length
    end
  end
end
