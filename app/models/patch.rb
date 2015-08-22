class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments, dependent: :destroy

  enum gitlab_ci_status: %i(unknown failed pass canceled)

  order :location

  validates :diff, presence: true
  validates :commit_message, presence: true

  after_create :push_to_ci

  delegate :author, to: :merge_request
  delegate :reviewer, to: :merge_request
  delegate :project, to: :merge_request
  delegate :target_branch, to: :merge_request

  def ok_to_retry_ci?
    failed? || canceled?
  end

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
    "mr-#{merge_request.id}-version-#{version}"
  end

  def version
    merge_request.patches.index(self) + 1
  end

  def subject
    commit_message.each_line.first
  end

  def commit_message(options = nil)
    msg = read_attribute(:commit_message)
    return msg.lines[1..-1].join.strip if options == :no_title
    msg
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

  def push_to_ci
    return if canceled? || !project.gitlab_ci?

    self.gitlab_ci_hash = nil
    self.gitlab_ci_status = :unknown
    save

    Git.new.clone(project.repository, target_branch) do |git|
      next unless git.ready?

      merge_request.deprecated_patches.each { |p| git.rm_branch(p.ci_branch_name) }
      if git.am(self)
        update_attribute(:gitlab_ci_hash, git.sha1) if git.push(ci_branch_name, :forced)
      else
        merge_request.needs_rebase!
      end
    end
  end

  private

  def reviewer_stamp
    return '' unless merge_request.accepted? or merge_request.integrating?
    "\nReviewed by #{reviewer.name} on MR ##{merge_request.id}\n"
  end
end
