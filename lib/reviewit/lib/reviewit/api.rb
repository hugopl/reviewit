require 'net/http'
require 'json'

module Reviewit
  class Api
    def initialize base_url, project_id, api_token
      @base_url = base_url
      @project_id = project_id
      @api_token = api_token
    end

    def update_merge_request mr_id, subject, commit_message, diff, comments
      puts 'Updating merge request...'
      patch("merge_requests/#{mr_id}", subject: subject, commit_message: commit_message, diff: diff, comments: comments)
      url = url_for("merge_requests/#{mr_id}")
      puts "Merge Request updated at #{url}"
    end

    def create_merge_request subject, commit_message, diff, target_branch
      puts "Creating merge request..."
      res = post('merge_requests', subject: subject, commit_message: commit_message, diff: diff, target_branch: target_branch)
      url = url_for("merge_requests/#{res['mr_id']}")
      puts "Merge Request created at #{url}"
      res['mr_id']
    end

  private

    def url_for path
      "#{@base_url}/projects/#{@project_id}/#{path}"
    end

    def full_uri_for path
      URI("#{url_for(path)}?api_token=#{@api_token}")
    end

    def post url, args
      send_request url, args, Net::HTTP::Post
    end

    def patch url, args
      send_request url, args, Net::HTTP::Patch
    end

    def send_request(url, params, method)
      url = full_uri_for(url)
      req = method.new(url)
      req.form_data = params
      res = Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https' ) do |http|
        http.request(req)
      end
      data = JSON.load(res.body)
      raise (data['error'] or 'Unknow error') if res.code != '200'
      return data
    rescue JSON::ParserError
      raise 'Error parsing returned JSON.'
    end
  end
end
