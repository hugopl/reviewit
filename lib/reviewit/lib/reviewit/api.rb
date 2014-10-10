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
    end

    def create_merge_request subject, commit_message, diff
      puts "Creating merge request..."
      res = post('merge_requests', subject: subject, commit_message: commit_message, diff: diff)
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
      res = Net::HTTP.post_form(full_uri_for(url), args)
      raise res.body if res.code != '200'
      JSON.load(res.body)
    end

    def patch url, args
      res = patch_form(full_uri_for(url), args)
      raise res.body if res.code != '200'
      JSON.load(res.body)
    end

    def patch_form(url, params)
      req = Net::HTTP::Patch.new(url)
      req.form_data = params
      Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https' ) do |http|
        http.request(req)
      end
    end

  end
end
