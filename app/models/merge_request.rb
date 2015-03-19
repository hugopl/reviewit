require 'tmpdir'
require 'fileutils'
require 'tempfile'

class MergeRequest < ActiveRecord::Base
  belongs_to :author, class_name: User
  belongs_to :reviewer, class_name: User
  belongs_to :project

  has_many :patches, -> { order(:created_at) }, dependent: :destroy
  has_many :history_events, -> { order(:when) }, dependent: :destroy

  enum status: [:open, :integrating, :needs_rebase, :accepted, :abandoned]

  # Any status >= this is considered a closed MR
  CLOSE_LIMIT = 3

  scope :pending, -> { where("status < #{CLOSE_LIMIT}") }
  scope :closed, -> { where("status >= #{CLOSE_LIMIT}") }

  validates :target_branch, presence: true
  validates :subject, presence: true
  validates :author, presence: true
  validate :author_cant_be_reviewer

  before_save :write_history

  def can_update?
    not %w(accepted integrating).include? status
  end

  def closed?
    MergeRequest.statuses[status] >= CLOSE_LIMIT
  end

  def add_patch(data)
    patch = Patch.new
    patch.commit_message = data[:commit_message]
    patch.diff = data[:diff]
    patch.linter_ok = data[:linter_ok]
    patch.description = data[:description]
    patches << patch
    add_history_event(author, 'updated the merge request') if persisted?
  end

  def add_comments(author, patch, comments)
    return if comments.nil?

    count = 0
    transaction do
      comments.each do |location, text|
        next if text.strip.empty?
        comment = Comment.new
        comment.user = author
        comment.patch = patch
        comment.content = text
        comment.location = location
        comment.save!
        count += 1
      end
    end
    add_history_event(author, count == 1 ? 'added a comment.' : "added #{count} comments.") unless count.zero?
  end

  def abandon!(reviewer)
    add_history_event reviewer, 'abandoned the merge request'
    self.status = :abandoned
    save!
  end

  def integrate!(reviewer)
    return if %w(accepted integrating abandoned).include? status
    add_history_event reviewer, 'accepted the merge request'

    self.reviewer = reviewer
    self.status = :integrating
    save!

    patch.push do |success|
      if success
        accepted!
      else
        add_history_event reviewer, 'failed to integrate merge request'
        needs_rebase!
      end
    end
  end

  def patch
    @patch ||= patches.last
  end

  def deprecated_patches
    patches.where.not(id: patch.id)
  end

  private

  def write_history
    add_history_event author, "changed the target branch from #{target_branch_was} to #{target_branch}" if target_branch_changed? and !target_branch_was.nil?
  end

  def add_history_event(who, what)
    history_events << HistoryEvent.new(who: who, what: what)
  end

  def indent_comment(comment)
    comment.each_line.map { |line| "    #{line}" }.join
  end

  def author_cant_be_reviewer
    errors.add(:reviewer, 'can\'t be the author.') if author == reviewer
  end
end
