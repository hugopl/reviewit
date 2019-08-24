module Reviewit
  class Projects < Grape::API
    helpers do
    end

    namespace :projects do
      route_param :project_id do
        mount MergeRequests

        format :txt
        get :setup do
          port = [80, 443].include?(request.port) ? '' : ":#{request.port}"
          is_ssl = request.ssl?
          root_url = "http#{is_ssl ? 's' : ''}://#{request.host}#{port}"
          gem_url = "#{root_url}/reviewit-#{Reviewit::VERSION}.gem"

          <<-eos
          @base_url = "#{root_url}/api"
          @api_token = #{current_user.api_token.inspect}
          @gem_url = #{gem_url.inspect}
          @project_name = #{project.name.inspect}
          @project_id = #{project.id}
          @linter = #{project.linter.inspect}
          @project_hash = #{project.configuration_hash.inspect}
          @gem_version = #{Reviewit::VERSION.inspect}

          @should_install = #{params[:no_install].nil?}

          #{File.read(Rails.root.join('lib', 'reviewit', 'install.rb'))}
          eos
        end

        desc 'Lock a branch'
        patch :lock do
          locked_branch = project.locked_branches.build(who: current_user, branch: params[:branch], reason: params[:reason])
          if locked_branch.save
            ok.to_json
          else
            raise locked_branch.errors.full_messages.join(', ')
          end
        end

        desc 'Unlock a branch'
        patch :unlock do
          n = project.locked_branches.where(branch: params[:branch]).delete_all
          raise 'Branch not locked, nothing done.' if n.zero?

          ok.to_json
        end
      end
    end
  end
end
