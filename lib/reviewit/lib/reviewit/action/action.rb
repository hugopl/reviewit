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

      # TODO: open user editor askign for a message.
      abort %(I didn't implement yet the code to open a editor and get the comments, sorry, use -m.)
    end

    def parse_options
      abort "Missing #{self.class}#parse_options implementation"
    end
  end
end
