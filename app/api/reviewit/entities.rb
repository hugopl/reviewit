module Reviewit
  module Entities
    class MergeRequest < Grape::Entity
      expose :id
      expose :subject
      expose :author
      expose :status
      expose :ci_status

      def author
        object.author.name
      end

      def ci_status
        object.patch.gitlab_ci_status
      end
    end

    class User < Grape::Entity
      expose :name
      expose :email
    end

    class FullMergeRequest < Grape::Entity
      expose :id
      expose :status
      expose :target_branch
      expose :patch
      expose :author, with: User
      expose :reviewer, with: User

      def patch
        object.git_format_patch
      end
    end
  end
end
