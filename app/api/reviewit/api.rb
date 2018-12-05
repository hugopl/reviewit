module Reviewit
  class Error < RuntimeError
    def initialize(msg, code)
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
    rescue_from ActiveRecord::RecordInvalid do |e|
      Rack::Response.new(e.message, 422).finish
    end
    rescue_from RuntimeError do |e|
      Rack::Response.new(e.message, 400).finish
    end
    rescue_from ActiveRecord::RecordNotFound do |e|
      Rack::Response.new(e.message, 404).finish
    end

    mount CI

    before do
      raise Error.new("Version #{Reviewit::VERSION} required.", 426) if version_changed?

      @current_user = User.find_by_api_token(headers['X-Token'])
      raise Error.new('Sorry, invalid token.', 401) if @current_user.nil?

      raise Error.new('Configuration changed.', 460) if configuration_changed?
    end

    helpers do
      def ok
        { message: :ok }
      end

      def project
        @project ||= Project.find(params[:project_id])
      end

      def setup_request?
        request.path =~ %r{/api/projects/\d+/setup}
      end

      def version_changed?
        return false if setup_request?

        headers['X-Cli-Version'] != Reviewit::VERSION
      end

      def configuration_changed?
        return false if setup_request?

        headers['X-Project-Hash'] != project.configuration_hash
      end

      attr_reader :current_user
    end

    mount Projects
  end
end
