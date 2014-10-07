require 'net/http'
require 'json'

module Rme
  class Api
    def initialize base_url, project_id, api_token
      @base_url = base_url
      @project_id = project_id
      @api_token = api_token
    end

    def update_merge_request subject, commit_message, diff, comments
      puts 'Updating merge request...'
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

    def post url, args
      uri = URI("#{url_for(url)}?api_token=#{@api_token}")
      res = Net::HTTP.post_form(uri, args)
      raise res.body if res.code != '200'
      JSON.load(res.body)
    end
  end
end
