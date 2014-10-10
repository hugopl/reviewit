module MergeRequestsHelper
  def patches
    @patches ||= @mr.patches
  end

  def patch
    @patch ||= patches.last
  end

  def merge_request_pending_since mr
    time = distance_of_time_in_words(Time.now, mr.patches.newer.updated_at)
    "pending for #{time}"
  end

  def process_diff diff, &block
    it = diff.each_line
    location = 0
    loop do
      line = it.next
      location += 1
      next unless line.start_with? '+++'
      diff_file = DiffFile.new(line, it, location)
      yield diff_file
      location = diff_file.location
    end
  rescue StopIteration
  end

  private

  class DiffFile
    def initialize line, it, location
      @it = it
      @location = location
      @name = line[6..-1]
    end

    attr_reader :name
    attr_reader :location

    def each_line
      old_ln = 0
      new_ln = 0
      loop do
        @location += 1
        diffline = DiffLine.new(@it.next, old_ln, new_ln, @location)
        yield diffline
        old_ln, new_ln = diffline.line_numbers
      end
    rescue StopIteration
    end
  end

  class DiffLine
    LINE_TYPES = {
      '@' => :info,
      '-' => :del,
      '+' => :add,
      ' ' => :nil
    }.freeze
    def initialize line, old_ln, new_ln, location
      @type = (LINE_TYPES[line.first] or :nil)
      @location = location

      if @type == :info
        @data = line[0..-1]
        @data =~ /@ -(\d+),\d+ \+(\d+),\d+/
        @old_ln = $1.to_i
        @new_ln = $2.to_i
      else
        @data = line[0..-2]
        @old_ln = old_ln
        @new_ln = new_ln

        @old_ln += 1 unless @type == :add
        @new_ln += 1 unless @type == :del
      end
    end

    attr_reader :data
    attr_reader :location

    def id
      0
    end

    def old_ln
      case @type
      when :add then ''
      when :info then '...'
      else @old_ln
      end
    end

    def new_ln
      case @type
        when :del then ''
        when :info then '...'
      else @old_ln
      end
    end

    def line_numbers
      [@old_ln, @new_ln]
    end

    def type
      @type == :nil ? '' : @type.to_s
    end
  end
end
