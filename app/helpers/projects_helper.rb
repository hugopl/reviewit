module ProjectsHelper
  def full_setup_url
    port = [80, 443].include?(request.port) ? '' : ":#{request.port}"
    is_ssl = request.ssl?
    "http#{is_ssl ? 's' : ''}://#{request.host}#{port}/api/projects/#{@project.id}/setup"
  end

  def merge_request_count project
    count = project.merge_requests.pending.count
    return 'No open merge requests' if count.zero?
    pluralize(count, 'merge request pending', 'merge requests pending')
  end
end
