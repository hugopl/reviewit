module ProjectsHelper
  def full_setup_url
    port = request.port != 80 ? ":#{request.port}" : ''
    "#{request.protocol}#{request.host}#{port}#{setup_project_path}?api_token=#{current_user.api_token}"
  end

  def merge_request_pending_since mr
    time = distance_of_time_in_words(Time.now, mr.patches.newer.updated_at)
    "pending for #{time}"
  end
end
