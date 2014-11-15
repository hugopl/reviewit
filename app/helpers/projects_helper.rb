module ProjectsHelper
  def full_setup_url
    port = request.port != 80 ? ":#{request.port}" : ''
    "http://#{request.host}#{port}/api/projects/#{@project.id}/setup"
  end
end
