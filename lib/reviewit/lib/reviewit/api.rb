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
      puts "Merge Request updated at #{mr_url(mr_id)}"
    end

    def create_merge_request subject, commit_message, diff, target_branch
      puts "Creating merge request..."
      res = post('merge_requests', subject: subject, commit_message: commit_message, diff: diff, target_branch: target_branch)
      puts "Merge Request created at #{mr_url(res['mr_id'])}"
      res['mr_id']
    end

  private

    def mr_url id
      @base_url.gsub(/api\/?\z/, "mr/#{id}")
    end

    def url_for path
      "#{@base_url}/projects/#{@project_id}/#{path}"
    end

    def full_uri_for path
      URI("#{url_for(path)}?api_token=#{@api_token}")
    end

    def post url, args
      send_request url, args
    end

    def patch url, args
      args[:_method] = 'patch'
      send_request url, args
    end

    def send_request(url, params)
      uri = full_uri_for(url)
      res = Net::HTTP.post_form(uri, params)
      data = JSON.load(res.body)
      raise (data['error'] or 'Unknow error') if res.code != '200'
      return data
    rescue JSON::ParserError
      raise 'Error parsing returned JSON.'
    end
  end
end
