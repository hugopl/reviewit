class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments, dependent: :destroy

  enum gitlab_ci_status: %i(unknown failed pass)

  order :location

  validates :diff, presence: true
  validates :commit_message, presence: true

  after_create :push_to_ci

  delegate :author, to: :merge_request
  delegate :reviewer, to: :merge_request
  delegate :project, to: :merge_request
  delegate :target_branch, to: :merge_request

  def comments_by_location
    comments.to_a.inject({}) do |hash, comment|
      location = comment.location.to_i
      unless location.zero?
        hash[location] ||= []
        hash[location] << comment
      end
      hash
    end
  end

  def ci_branch_name
    index = merge_request.patches.index(self) + 1
    "mr-#{id}-version-#{index}"
  end

  def formatted
    <<eot
From: #{author.name} <#{author.email}>
Date: #{created_at.strftime('%a, %d %b %Y %H:%M:%S %z')}

#{commit_message}
#{reviewer_stamp}
#{diff}
--
review it!
eot
  end

  def push
    LoggedGit.new.clone(project.repository, target_branch) do |git|
      yield(git.ready? && git.am(self) && git.push(target_branch))

      self.integration_log = git.command_log
      save

      next unless git.ready?
      git.rm_branch(ci_branch_name) unless gitlab_ci_hash.blank?
    end
  end

  def remove_ci_branch
    return if gitlab_ci_hash.blank?
    Git.new.clone(project.repository) do |git|
      next unless git.ready?
      git.rm_branch(ci_branch_name)
    end
  end

  private

  def push_to_ci
    return if gitlab_ci_hash.blank?

    Git.new.clone(project.repository, target_branch) do |git|
      next unless git.ready?

      merge_request.deprecated_patches.each { |p| git.rm_branch(p.ci_branch_name) }

      if git.am(patch) and git.push(patch.ci_branch_name)
        patch.gitlab_ci_hash = git.sha1
        patch.save
      end
    end
  end

  def reviewer_stamp
    return '' unless merge_request.accepted? or merge_request.integrating?
    "\nReviewed by #{reviewer.name} on MR ##{id}\n"
  end
end
