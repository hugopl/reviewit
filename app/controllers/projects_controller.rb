require Rails.root.join('lib', 'r-me', 'lib', 'r-me', 'version.rb')

class ProjectsController < ApplicationController
  before_action :authenticate_user!, :except => [:setup]

  def show
    @project = current_user.projects.find_by_id(params[:id])
  end

  def setup
    @user = User.find_by_api_token(params[:api_token]) or raise 'Sorry, invalid token or project.'
    if @user
      @project = @user.projects.find_by_id(params[:id]) or raise 'Invalid project.'
      render text: r_me_script
    end
  rescue
    render text: "puts '#{$!.message}'", status: :unauthorized
  end
private
  def r_me_script
    port = request.port != 80 ? ":#{request.port}" : ''
    gem_url = "#{request.protocol}#{request.host}#{port}/r-me-#{Rme::VERSION}.gem"

    <<eos
$base_url = "#{request.protocol}#{request.host}#{port}"
$api_token = "#{@user.api_token}"
$gem_url = "#{gem_url}"
$project_name = "#{@project.name.gsub('"', '\"')}"
$project_id = #{@project.id}

#{File.read(Rails.root.join('lib', 'r-me', 'install.rb'))}
eos
  end
end
