require 'tempfile'

module Reviewit
  class Action
    def initialize(api)
      @api = api

      @options = parse_options
    end
  protected

    NO_COLOR = "\033[0m"
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    WHITE = "\033[1;37m"
    CYAN = "\033[0;36m"

    MR_STAMP = 'Reviewit-MR-id:'
    MR_STAMP_REGEX = /^#{MR_STAMP} (?<id>\d+)$/

    attr_reader :api
    attr_reader :options

    def read_commit_header
      @subject = `git show -s --format="%s"`.strip
      @commit_message = `git show -s --format="%B"`.strip
    end

    def process_commit_message!
      match = MR_STAMP_REGEX.match @commit_message

      if match
        @commit_message["#{match}"] = ''
        @mr_id = match[:id]
      end
      @commit_message.strip!
    end

    def read_user_single_line_message prompt
      print prompt
      STDIN.readline.strip
    end

    def read_user_message
      return @options[:message] if @options[:message_given]

      editor = (ENV['EDITOR'] or ENV['VISUAL'] or 'nano')
      message_file = Tempfile.new 'reviewit'
      message_file.puts "# Write something about your changes."
      message_file.flush

      res = system("#{editor} #{message_file.path}")
      raise 'Can\'t open an editor, set eht EDITOR or VISUAL environment variables. Or just install nano :-)' if res.nil?
      comments = File.read message_file.path

      comments = comments.lines.select {|line| line =~ /^[^#]/}
      comments.join.strip
    end

    def parse_options
      abort "Missing #{self.class}#parse_options implementation"
    end
  end
end
