module Rme
  class Action
    def initialize(api, options)
      @api = api
      @options = options
    end
  protected
    attr_reader :api

    def read_user_message
      return @options[:message] if @options[:message_given]

      # TODO: open user editor askign for a message.
      %(Let's say you wrote a nice message)
    end
  end
end
