require 'tempfile'
require 'shellwords'

module Reviewit
  class Action
    def initialize(app, api)
      @api = api

      @linter = app.linter
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
    attr_reader :linter

    def commit_message
      @commit_message ||= `git show -s --format="%B"`.strip
    end

    def mr_id_from_head
      match = MR_STAMP_REGEX.match(commit_message)
      match[:id] if match
    end

    def read_user_single_line_message(prompt)
      print prompt
      STDIN.readline.strip
    end

    def read_user_message
      return @options[:message] if @options[:message_given]

      editor = (ENV['EDITOR'] or ENV['VISUAL'] or 'nano')
      message_file = Tempfile.new 'reviewit'
      message_file.puts '# Write something about your changes.'
      message_file.flush

      res = system("#{editor} #{message_file.path}")
      raise 'Can\'t open an editor, set eht EDITOR or VISUAL environment variables. Or just install nano :-)' if res.nil?
      comments = File.read message_file.path

      comments = comments.lines.select { |line| line =~ /^[^#]/ }
      comments.join.strip
    end

    def check_dirty_working_copy!
      raise 'Your working copy is dirty, use git stash and try again.' unless `git status --porcelain`.empty?
    end

    def parse_options
      abort "Missing #{self.class}#parse_options implementation"
    end

    def root_dir
      @root_dir ||= `git rev-parse --show-toplevel`.strip
    end

    def copy_to_clipboard(text)
      text = Shellwords.escape(text)
      case RUBY_PLATFORM
      when /linux/
        copy_to_clipboard_linux(text)
      when /darwin/
        copy_to_clipboard_mac(text)
      end
    rescue
      false
    end

    def copy_ruby_platform_linux(text)
      IO.popen('xclip -selection clipboard', 'w') { |f| f << text }
    end

    def copy_ruby_platform_mac(text)
      IO.popen('pbcopy', 'w') { |f| f << text }
    end
  end
end
