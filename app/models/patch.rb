class Patch < ApplicationRecord
  belongs_to :merge_request, touch: true

  has_many :comments, dependent: :destroy

  enum gitlab_ci_status: %i(unknown failed success canceled pending running)

  order :location

  validates :diff, presence: true
  validates :commit_message, length: { minimum: 0 }, allow_nil: false

  after_create :update_jira_ticket
  after_commit :really_push_to_ci, on: :create, unless: :canceled?

  delegate :author, to: :merge_request
  delegate :reviewer, to: :merge_request
  delegate :project, to: :merge_request
  delegate :target_branch, to: :merge_request
  delegate :subject, to: :merge_request

  before_save :fix_author

  def ok_to_retry_ci?
    (failed? || canceled?) && self == merge_request.patch
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

  def push_to_ci
    unknown!
    really_push_to_ci
  end

  private

  def fix_author
    self.diff = diff.sub(/^From: .*$/, "From: #{author.name} <#{author.email}>")
  end

  # This method exists because we can't change ourselves under a after_commit callback.
  def really_push_to_ci
    GitPushWorker.perform_async(id, :ci) if project.gitlab_ci?
  end

  def mr_stamp
    "Reviewit-MR-id: #{merge_request.id}\n"
  end

  def reviewer_stamp
    return unless merge_request.accepted? or merge_request.integrating?

    "Reviewed by #{reviewer.name} on MR ##{merge_request.id}\n"
  end

  def update_jira_ticket(silent: false)
    return unless project.jira_enabled?

    ticket = Regexp.new(project.jira_ticket_regexp).match(commit_message)
    return if ticket.nil?

    url = Regexp.new("https:\/\/[^ ]*#{ticket}").match(commit_message)

    merge_request.jira_ticket = ticket.to_s
    merge_request.jira_url = url.to_s

    merge_request.notify_jira if !silent && merge_request.jira_ticket_changed?
    merge_request.save!
  end
end
