module Api
  class ProjectsController < ApiController
    before_action :check_cli_version!, except: [:setup]

    def setup
      render text: r_me_script
    end

    private

    def r_me_script
      port = request.port != 80 ? ":#{request.port}" : ''
      gem_url = "#{request.protocol}#{request.host}#{port}/reviewit-#{Reviewit::VERSION}.gem"

      <<-eos
      $base_url = "#{request.protocol}#{request.host}#{port}/api"
      $api_token = #{current_user.api_token.inspect}
      $gem_url = #{gem_url.inspect}
      $project_name = #{project.name.inspect}
      $project_id = #{@project.id}
      $linter = #{project.linter.inspect}

      #{File.read(Rails.root.join('lib', 'reviewit', 'install.rb'))}
      eos
    end
  end
end
