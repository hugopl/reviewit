class ProjectsController < ApplicationController
  before_action :authenticate_user!, :except => [:setup]

  def show
    @project = current_user.projects.find_by_id(params[:id])
  end

  def setup
    if User.valid_token?(params[:api_token])
      render text: r_me_script
    else
      render text: 'puts "Sorry, invalid token."', status: :unauthorized
    end
  end
private
  def r_me_script
    installer = File.read(Rails.root.join('lib', 'r-me', 'install.rb'))
  end
end
