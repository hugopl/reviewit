require 'set'

class String
  TRUES = Set.new([true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON']).freeze

  def true?
    TRUES.include?(self)
  end
end

class Object
  def true?
    self
  end
end

module Reviewit
  class MergeRequests < Grape::API
    helpers do
      def merge_request
        MergeRequest.find(params[:mr_id])
      end
    end

    resource :merge_requests do
      desc 'List pending merge requests.'
      get do
        present project.merge_requests.includes(:author).pending, with: Entities::MergeRequest
      end

      desc 'Create a new merge request'
      post do
        MergeRequest.transaction do
          mr = MergeRequest.new
          diff = Diff.new(params[:diff])
          mr.project = project
          mr.author = current_user
          mr.subject = diff.subject
          mr.target_branch = params[:target_branch]
          mr.add_patch(diff: diff,
                       linter_ok: params[:linter_ok].true?,
                       ci_enabled: params[:ci].true?)
          mr.save!
          MergeRequestMailer.created(mr).deliver_now
          { mr_id: mr.id }
        end
      end

      route_param :mr_id do
        desc 'Show a merge request.'
        get do
          present merge_request, with: Entities::FullMergeRequest
        end

        desc 'Update a merge request.'
        patch do
          mr = merge_request

          raise 'You need to be the MR author to update it.' if mr.author != current_user
          raise "You can not update an #{mr.status} merge request." unless mr.can_update?

          MergeRequest.transaction do
            diff = Diff.new(params[:diff])
            mr.subject = diff.subject
            mr.target_branch = params[:target_branch] unless params[:target_branch].blank?
            mr.status = :open
            mr.add_patch(diff: diff,
                         linter_ok: params[:linter_ok].true?,
                         description: (params[:description] or '').lines.first.to_s,
                         ci_enabled: params[:ci].true?)
            mr.save!
          end
          ok
        end

        desc 'Accept a merge request'
        patch :accept do
          raise 'This merge request was already accepted.' if merge_request.accepted? or merge_request.integrating?

          merge_request.integrate! current_user
          ok
        end

        desc 'Abandon a merge request'
        delete do
          raise 'You can not abandon a merge request in the integration process, wait a bit.' if merge_request.integrating?
          raise 'Too late, this merge request was already accepted.' if merge_request.accepted?
          raise 'This merge request was already abandoned.' if merge_request.abandoned?

          merge_request.abandon! current_user
          ok
        end
      end
    end
  end
end
