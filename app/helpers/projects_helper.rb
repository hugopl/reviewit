module ProjectsHelper
  def full_setup_url
    port = [80, 443].include?(request.port) ? '' : ":#{request.port}"
    is_ssl = request.ssl?
    "http#{is_ssl ? 's' : ''}://#{request.host}#{port}/api/projects/#{@project.id}/setup"
  end
end
