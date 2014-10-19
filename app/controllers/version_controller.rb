class VersionController < ApplicationController

  def show
    @version = params[:id].to_i

    redirect_to project_merge_request_path(@project, @mr) if @version == merge_request.patches.count
    @patch = merge_request.patches[@version - 1]
    raise ActiveRecord::RecordNotFound.new if @patch.nil?
  end

  private

  def merge_request
    @mr ||= project.merge_requests.find(params[:merge_request_id])
  end

end
