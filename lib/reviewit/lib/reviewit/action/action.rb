require 'tempfile'

module Reviewit
  class Action
    def initialize(api)
      @api = api

      @options = parse_options
    end
  protected
    attr_reader :api
    attr_reader :options

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
