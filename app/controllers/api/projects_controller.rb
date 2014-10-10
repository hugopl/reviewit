require Rails.root.join('lib', 'reviewit', 'lib', 'reviewit', 'version.rb')

module Api
  class ProjectsController < ApiController
    def setup
      render text: r_me_script
    end

    private

    def r_me_script
      port = request.port != 80 ? ":#{request.port}" : ''
      gem_url = "#{request.protocol}#{request.host}#{port}/reviewit-#{Reviewit::VERSION}.gem"

      <<-eos
      $base_url = "#{request.protocol}#{request.host}#{port}/api"
      $api_token = "#{current_user.api_token}"
      $gem_url = "#{gem_url}"
      $project_name = "#{project.name.gsub('"', '\"')}"
      $project_id = #{@project.id}

      #{File.read(Rails.root.join('lib', 'r-me', 'install.rb'))}
      eos
    end
  end
end
