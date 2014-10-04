module ProjectsHelper
  def full_setup_url
    port = request.port != 80 ? ":#{request.port}" : ''
    "#{request.protocol}#{request.host}#{port}#{setup_project_path}?api_token=#{current_user.api_token}"
  end
end
