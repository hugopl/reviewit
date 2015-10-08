class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments, dependent: :destroy

  enum gitlab_ci_status: %i(unknown failed pass canceled)

  order :location

  validates :diff, presence: true
  validates :commit_message, length: { minimum: 0 }, allow_nil: false

  after_create :push_to_ci_if_neded

  delegate :author, to: :merge_request
  delegate :reviewer, to: :merge_request
  delegate :project, to: :merge_request
  delegate :target_branch, to: :merge_request

  before_save :fix_author

  def ok_to_retry_ci?
    failed? || canceled?
  end

  def ci_branch_name
    "mr-#{merge_request.id}-version-#{version}"
  end

  def version
    merge_request.patches.index(self) + 1
  end

  def code_at(location)
    @lines ||= diff.lines
    @lines[location]
  end

  # Stamp can be: reviewer, reviewit or nil
  # For Reviewed-by or Reviewit-MR-id
  def diff(stamp: false)
    return self[:diff] if !stamp || merge_request.nil?

    text = reviewer_stamp
    text ||= mr_stamp
    self[:diff].sub(/^diff --git /, "#{text}\ndiff --git ")
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
    return unless project.gitlab_ci?

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

  def fix_author
    self.diff = diff.sub(/^From: .*$/, "From: #{author.name} <#{author.email}>")
  end

  def push_to_ci_if_neded
    push_to_ci unless canceled?
  end

  def mr_stamp
    "Reviewit-MR-id: #{merge_request.id}\n"
  end

  def reviewer_stamp
    return unless merge_request.accepted? or merge_request.integrating?
    "Reviewed by #{reviewer.name} on MR ##{merge_request.id}\n"
  end
end
