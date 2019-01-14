class Diff
  # Source can be :git or :interdiff
  def initialize(diff, source: :git)
    @raw = diff
    @files = {}
    @message_lines = []
    @file_metadata_reader = source == :git ? :start_reading_git_file_metadata : :start_reading_interdiff_file_metadata
    process_patch(diff)
    process_subject

    @commit_message = @message_lines.join
  end

  def each_file
    @files.each do |_name, value|
      yield value
    end
  end

  def empty?
    @files.empty?
  end

  attr_reader :files
  attr_reader :subject
  attr_reader :commit_message
  attr_reader :raw

  private

  def process_subject
    return '' if @subject.nil?
    # Subject can be Q-Encoded.
    @subject[0] = @subject[0].sub('[PATCH] ', '')
    @subject.map! do |line|
      if line.start_with?('=?UTF-8?q?') && line.end_with?('?=')
        line.byteslice(10, line.size - 12).unpack('M').first
      else
        line
      end
    end
    @subject = @subject.join
  end

  public

  class File
    attr_accessor :name
    attr_accessor :changes
    attr_accessor :renamed_from
    attr_accessor :old_chmod
    attr_accessor :new_chmod
    attr_accessor :index
    attr_accessor :similarity
    attr_accessor :binary
    attr_accessor :interdiff_tag
    alias binary? binary
    attr_writer :status

    def initialize
      @changes = []
    end

    def new?
      @status == :new
    end

    def deleted?
      @status == :deleted
    end

    def renamed?
      @status == :renamed
    end

    def chmod_changed?
      !@new_chmod.nil?
    end

    def label
      return @name unless renamed?

      @label ||= path_diff(@renamed_from, @name)
    end

    def each_change
      old_ln = old_ln_cache = 0
      new_ln = new_ln_cache = 0

      @changes.each_with_index do |line, i|
        if line =~ /@ -(\d+),\d+ \+(\d+),\d+/
          old_ln_cache = $1.to_i
          new_ln_cache = $2.to_i
        end

        type = LINE_TYPES[line[0]]
        case type
        when :add
          old_ln = ''
          new_ln = new_ln_cache
          new_ln_cache += 1
        when :del
          old_ln = old_ln_cache
          old_ln_cache += 1
          new_ln = ''
        when :info
          old_ln = new_ln = '...'
        else
          new_ln = new_ln_cache
          old_ln = old_ln_cache
          old_ln_cache += 1
          new_ln_cache += 1
        end

        yield(line, type, @index + i, old_ln, new_ln)
      end
    end

    private

    LINE_TYPES = {
      '@' => :info,
      '-' => :del,
      '+' => :add,
      ' ' => :nil
    }

    def path_diff(from, to)
      old_parts = from.split('/')
      new_parts = to.split('/')
      output = []
      old_changed = []
      new_changed = []
      change_blocks = 0
      i = -1
      old_parts.reverse_each do |old_dir|
        new_dir = new_parts[i]
        if old_dir == new_dir
          if old_changed.any?
            output << "{#{old_changed.reverse.join('/')} → #{new_changed.reverse.join('/')}}" if new_changed.any?
            change_blocks += 1
          end
          output << old_dir

          old_changed = []
          new_changed = []
        elsif change_blocks == 1
          change_blocks += 1
          break
        else
          old_changed << old_dir
          new_changed << new_dir
        end
        i -= 1
      end

      missing_path_parts = -i <= new_parts.length
      output.clear if old_changed.empty? && missing_path_parts

      return "#{from} => #{to}" if change_blocks > 1 || output.empty?

      if missing_path_parts
        range = new_parts.length + i
        new_changed += new_parts[0..range].reverse
      end

      output << "{#{old_changed.reverse.join('/')} → #{new_changed.reverse.join('/')}}" if new_changed.any?
      output.reverse.join('/')
    end
  end

  private

  def process_patch(diff)
    @state = :state_idle
    @index = -1
    diff.each_line do |line|
      @index += 1
      next if send(@file_metadata_reader, line)

      send(@state, line)
    end
  end

  def state_idle(line)
    if line =~ /^Subject: (.*)/
      @subject = [$1]
      @state = :state_reading_subject
    end
    @state = :state_reading_commit_message if line.blank?
  end

  def state_reading_subject(line)
    @subject << $1[1..-1] if line =~ /^( .+)/
    @state = :state_reading_commit_message if line.blank?
  end

  def state_reading_commit_message(line)
    @message_lines << line
  end

  def start_reading_git_file_metadata(line)
    return false unless line.start_with?('diff --git ')

    @file = File.new
    line =~ %r{^diff --git a/(.*) b/(.*)}
    @file.name = $2 == '/dev/null' ? $1 : $2
    @files[@file.name] = @file
    @state = :state_reading_file_metadata
  end

  def start_reading_interdiff_file_metadata(line)
    new_file_line = line =~ /^(diff -u|---|\+\+\+)/
    interdiff_tag = line =~ /^(reverted|unchanged|only in patch2|only in patch1)/
    return false if !new_file_line && !interdiff_tag

    new_file_found = !interdiff_tag && (line.start_with?('diff') || @next_interdiff_tag)

    if interdiff_tag
      @next_interdiff_tag = $1.capitalize
    elsif new_file_found
      if line.start_with?('diff')
        line =~ %r{^diff -u .?/(.*) .?/(.*)}
        file_name = $2 == '/dev/null' ? $1 : $2
      else
        line =~ %r{^... ./(.*)}
        return true if $1.nil?

        file_name ||= $1
      end
      @file = File.new
      @file.name = file_name
      @file.interdiff_tag = @next_interdiff_tag
      @next_interdiff_tag = nil
      @files[@file.name] = @file

      if line.start_with?('+++')
        @file.index = 0 # Don't care about index on interdiffs
        @state = :state_reading_file_changes
      else
        @state = :state_reading_file_metadata
      end
    end
  end

  def state_reading_file_metadata(line)
    case line
    when /^new file mode (.+)/
      @file.status = :new
      @file.new_chmod = $1
    when /^deleted file mode/
      @file.status = :deleted
    when /^rename from (.+)/
      @file.status = :renamed
      @file.renamed_from = $1
    when /^rename to (.+)/
      @file.name = $1
    when /^similarity index (.+)/
      @file.similarity = $1
    when /^old mode (.+)/
      @file.old_chmod = $1
    when /^new mode (.+)/
      @file.new_chmod = $1
    when /^\+\+\+ /
      @state = :state_reading_file_changes
      @file.index = @index + 1
    when /^GIT binary patch$/
      @file.binary = true
      @file.index = @index + 1
      @file.changes << 'This is a binary file, code to view it here is not done yet :-('
      @state = :state_reading_file_changes
      nil
    end
  end

  def state_reading_file_changes(line)
    return if @file.binary?

    if line == "-- \n"
      @state = :state_idle
    else
      line.chop! if line.end_with?("\n")
      @file.changes << line
    end
  end
end
