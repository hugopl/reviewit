require 'net/http'
require 'openssl'
require 'json'

module Reviewit
  class RetryExpected < RuntimeError
  end

  class Api
    def initialize(base_url, project_id, api_token, project_hash)
      @base_url = base_url
      @project_id = project_id
      @api_token = api_token
      @project_hash = project_hash
    end

    def update_merge_request(id, data)
      patch("merge_requests/#{id}", data)
      mr_url(id)
    end

    def create_merge_request(data)
      res = post('merge_requests', data)
      { url: mr_url(res['mr_id']), id: res['mr_id'] }
    end

    def abandon_merge_request(id)
      delete("merge_requests/#{id}")
    end

    def accept_merge_request(id)
      patch("merge_requests/#{id}/accept")
    end

    def lock_branch(branch, reason)
      patch('lock', branch: branch, reason: reason)
    end

    def unlock_branch(branch)
      patch('unlock', branch: branch)
    end

    def pending_merge_requests
      list = get 'merge_requests'
      list.map do |item|
        {
          id: item['id'],
          target: item['target_branch'],
          status: item['status'],
          subject: item['subject'],
          ci_status: item['ci_status']
        }
      end
    end

    def merge_request(id)
      get "merge_requests/#{id}"
    end

    def mr_url(id)
      @base_url.gsub(%r{api/?\z}, "mr/#{id}")
    end

    private

    def url_for(path)
      "#{@base_url}/projects/#{@project_id}/#{path}"
    end

    def post(url, args)
      send_request url, args
    end

    def patch(url, args = {})
      args[:_method] = 'patch'
      send_request url, args
    end

    def delete(url)
      args = { _method: 'delete' }
      send_request url, args
    end

    def get(url)
      send_request(url, {}, :get)
    end

    def send_request(relative_url, params, method = :post)
      klass = method == :get ? Net::HTTP::Get : Net::HTTP::Post

      uri = URI(url_for(relative_url))
      req = klass.new(uri.to_s)
      req['X-Token'] = @api_token
      req['X-Cli-Version'] = VERSION
      req['X-Project-Hash'] = @project_hash
      req.set_form_data(params) unless params.empty?

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

      response = http.start { |h| h.request(req) }

      if block_given?
        yield response
      else
        process_response(response)
      end
    end

    def process_response(response)
      upgrade_and_exit! if response.code == '426'
      update_configuration_and_exit! if response.code == '460'

      raise response.body if response.code =~ /[^2]\d\d/

      data = JSON.parse(response.body)
      data
    rescue JSON::ParserError
      raise 'Error parsing returned JSON.'
    end

    def upgrade_and_exit!
      send_request('setup', {}, :get) do |response|
        eval response.body
      end
      raise RetryExpected, 'New version of reviewit installed!'
    end

    def update_configuration_and_exit!
      send_request('setup', { no_install: true }, :get) do |response|
        eval response.body
      end
      raise RetryExpected, 'Project configuration updated!'
    end
  end
end
