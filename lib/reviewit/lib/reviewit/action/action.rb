module Reviewit
  class Action
    def initialize(api)
      @api = api

      @options = parse_options
    end
  protected
    attr_reader :api

    def read_user_message
      return @options[:message] if @options[:message_given]

      # TODO: open user editor askign for a message.
      %(Let's say you wrote a nice message)
    end

    def parse_options
      abort "Missing #{self.class}#parse_options implementation"
    end
  end
end
