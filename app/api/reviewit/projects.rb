module Reviewit
  class Projects < Grape::API
    helpers do
      def project
        @projects ||= Project.find(params[:project_id])
      end
    end

    namespace :projects do
      route_param :project_id do
        mount MergeRequests

        format :txt
        get :setup do
          port = request.port != 80 ? ":#{request.port}" : ''
          gem_url = "http://#{request.host}#{port}/reviewit-#{Reviewit::VERSION}.gem"

          <<-eos
          $base_url = "http://#{request.host}#{port}/api"
          $api_token = #{current_user.api_token.inspect}
          $gem_url = #{gem_url.inspect}
          $project_name = #{project.name.inspect}
          $project_id = #{project.id}
          $linter = #{project.linter.inspect}
          $gem_version = #{Reviewit::VERSION.inspect}

          #{File.read(Rails.root.join('lib', 'reviewit', 'install.rb'))}
          eos
        end
      end
    end
  end
end
