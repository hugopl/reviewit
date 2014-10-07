require Rails.root.join('lib', 'r-me', 'lib', 'r-me', 'version.rb')

class ProjectsController < ApplicationController
  before_action :authenticate_user!, :except => [:setup]
  before_action :authenticate_user_by_token!, :only => [:setup]

  def show
    @project = current_user.projects.find_by_id(params[:id])
  end

  def setup
    render text: r_me_script
  end

private

  def r_me_script
    port = request.port != 80 ? ":#{request.port}" : ''
    gem_url = "#{request.protocol}#{request.host}#{port}/r-me-#{Rme::VERSION}.gem"

    <<eos
$base_url = "#{request.protocol}#{request.host}#{port}"
$api_token = "#{current_user.api_token}"
$gem_url = "#{gem_url}"
$project_name = "#{project.name.gsub('"', '\"')}"
$project_id = #{@project.id}

#{File.read(Rails.root.join('lib', 'r-me', 'install.rb'))}
eos
  end
end
