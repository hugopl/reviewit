module MergeRequestsHelper
  def patches
    @patches ||= @mr.patches
  end

  def patch
    @patch ||= patches.last
  end

  def patch_name(patch)
    i = @mr.patches.index(patch) + 1
    patch.description.blank? ? "#{i.ordinalize} version" : patch.description
  end

  def merge_request_pending_since(mr)
    last_patch = mr.patches.last
    return '' unless last_patch.is_a? Patch
    time = (last_patch.updated_at or last_patch.created_at)
    time = distance_of_time_in_words(Time.now, time)
    "pending for #{time}"
  end

  def gitlab_ci_icon(mr)
    patch = mr.patch
    if patch.pass?
      content_tag(:i, '', class: 'tipped fa fa-check ok', 'data-tip' => 'CI build passed!')
    elsif patch.failed?
      content_tag(:i, '', class: 'tipped fa fa-remove fail', 'data-tip' => 'CI build failed!')
    end
  end

  # TODO: Refactor this shitty code
  def process_diff(diff)
    it = diff.each_line
    location = 0
    loop do
      line = it.next
      location += 1
      is_file_def = line.start_with?('+++') || line.start_with?('---')
      next unless is_file_def and line !~ %r{\A(\-\-\-|\+\+\+) /dev/null$}

      diff_file = DiffFile.new(line, it, location)
      yield diff_file
      location = diff_file.location
    end
  rescue StopIteration
    return
  end

  def summary_addons(patch)
    addons = patch.project.summary_addons
    return if addons.nil?
    addons.each_line do |line|
      label, template = line.split(':', 2)
      template = parse_addons_template(template, patch)
      yield label, template
    end
  end

  private

  def parse_addons_template(template, patch)
    template.gsub!('#{mr_id}', patch.merge_request.id.to_s)
    template.gsub!('#{mr_version}', patch.version.to_s)
  end

  class DiffFile
    def initialize(line, it, location)
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
        line = @it.next
        is_file_def = line.start_with?('+++') || line.start_with?('---')
        line = @it.next if is_file_def
        return if line.start_with? 'diff'
        diffline = DiffLine.new(line, old_ln, new_ln, @location)
        yield diffline
        old_ln, new_ln = diffline.line_numbers
      end
    rescue StopIteration
      return
    end
  end

  class DiffLine
    LINE_TYPES = {
      '@' => :info,
      '-' => :del,
      '+' => :add,
      ' ' => :nil
    }.freeze
    def initialize(line, old_ln, new_ln, location)
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
      else @new_ln
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
