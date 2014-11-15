module Reviewit

  class Error < RuntimeError
    def initialize msg, code
      super msg
      @code = code
    end

    attr_reader :code
  end

  class API < Grape::API
    version 'v1', using: :accept_version_header, vendor: :reviewit
    format :json
    prefix :api

    rescue_from Error do |e|
      Rack::Response.new(e.message, e.code).finish
    end
    rescue_from RuntimeError do |e|
      Rack::Response.new(e.message, 400).finish
    end
    rescue_from ActiveRecord::RecordNotFound do |e|
      Rack::Response.new(e.message, 404).finish
    end

    before do
      if not request.path =~ /\/api\/projects\/\d+\/setup/
        raise Error.new("Version #{Reviewit::VERSION} required.", 426) if headers['X-Cli-Version'] != Reviewit::VERSION
      end
      raise Error.new('Sorry, invalid token.', 401) unless @current_user = User.find_by_api_token(headers['X-Token'])
    end

    helpers do
      def ok
        { message: :ok }
      end

      def current_user
        @current_user
      end
    end

    mount Projects
  end
end
