class Diff
  def initialize(diff)
    @raw = diff
    @files = {}
    @message_lines = []
    process_patch(diff)

    @subject = @message_lines.shift || ''
    @subject.sub!('[PATCH] ', '')
    @commit_message = @message_lines.join
    @commit_message.strip!
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

  class File
    attr_accessor :name
    attr_accessor :changes
    attr_accessor :renamed_from
    attr_accessor :old_chmod
    attr_accessor :new_chmod
    attr_accessor :index
    attr_accessor :similarity
    attr_accessor :binary
    alias_method :binary?, :binary
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
      from = from.split('/')
      to = to.split('/')
      output = []
      from.each_with_index do |f, i|
        if f == to[i]
          output << f
        else
          output << "{#{f} → #{to[i]}}"
        end
      end
      output.join('/')
    end
  end

  private

  attr_writer :state

  def process_patch(diff)
    @state = :state_idle
    @index = 0
    diff.each_line do |line|
      @index += 1
      next if read_file_metadata_if_possible(line)
      send(@state, line)
    end
  end

  def read_file_metadata_if_possible(line)
    return false unless line.start_with?('diff --git ')
    start_reading_file_metadata(line)
    true
  end

  def state_idle(line)
    if line =~ /^Subject: (.*)/
      @message_lines << $1
      self.state = :state_reading_subject
    end
    self.state = :state_reading_commit_message if line.blank?
  end

  def state_reading_subject(line)
    @message_lines[0] += $1 if line =~ /^( .+)/
    self.state = :state_reading_commit_message if line.blank?
  end

  def state_reading_commit_message(line)
    @message_lines << line
  end

  def start_reading_file_metadata(line)
    @file = File.new
    line =~ %r{^diff --git a/(.*) b/(.*)}
    @file.name = $2 == '/dev/null' ? $1 : $2
    @files[@file.name] = @file
    self.state = :state_reading_file_metadata
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
      self.state = :state_reading_file_changes
      @file.index = @index + 1
    when /^GIT binary patch$/
      @file.binary = true
      @file.index = @index + 1
      @file.changes << 'This is a binary file, code to view it here is not done yet :-('
      self.state = :state_reading_file_changes
    end
  end

  def state_reading_file_changes(line)
    return self.state = :state_idle if line == "-- \n"
    return if @file.binary?

    line.chop! if line.end_with?("\n")
    @file.changes << line
  end
end
