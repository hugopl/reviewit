class MergeRequestsController < ApplicationController
  before_action :authenticate_user!, :only => [:show]
  before_action :authenticate_user_by_token!, :only => [:create, :update]

  def create
    mr = MergeRequest.new
    mr.project = project
    mr.owner = current_user
    mr.subject = params[:subject]
    mr.commit_message = params[:commit_message]
    mr.save!

    patch = Patch.new
    patch.merge_request = mr
    patch.diff = params[:diff]
    patch.save!

    result = { :mr_id => mr.id }
    render json: result
  end

  def update
    render json: "oi"
  end

  def show
    render text: "oi"
  end
end
