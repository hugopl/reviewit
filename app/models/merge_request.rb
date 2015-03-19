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

    Thread.new do
      begin
        on_git_repository(patch) do |dir|
          if git_am(dir, patch) and git_push(dir, target_branch)
            accepted!
          else
            add_history_event reviewer, 'failed to integrate merge request'
            needs_rebase!
          end

          git_rm_branch(dir, gitlab_ci_branch_name(patch)) unless patch.gitlab_ci_hash.blank?
        end
      rescue
        output.puts "\n\n******** Stupid error from Review it! programmer ******** \n\n"
        output.puts $!.inspect
        output.puts $!.backtrace
        open!
      ensure
        patch.integration_log = output.string
        patch.save
        ActiveRecord::Base.connection.close
      end
    end
  end

  def push_to_gitlab_ci(patch)
    Thread.new do
      begin
        on_git_repository(patch) do |dir|
          git_prune_old_versions(dir, patch)
          if git_am(dir, patch) and git_push(dir, gitlab_ci_branch_name(patch))
            patch.gitlab_ci_hash = git_hash(dir)
            patch.save
          end
        end
      rescue
        Rails.logger.error $!.backtrace
      ensure
        ActiveRecord::Base.connection.close
      end
    end
  end

  def patch
    @patch ||= patches.last
  end

  def git_format_patch(patch = nil)
    patch ||= self.patch
    return if patch.nil?

    <<eot
From: #{author.name} <#{author.email}>
Date: #{patch.created_at.strftime('%a, %d %b %Y %H:%M:%S %z')}

#{patch.commit_message}
#{reviewer_stamp}
#{patch.diff}
--
review it!
eot
  end

  private

  def reviewer_stamp
    return '' unless accepted? or integrating?
    "\nReviewed by #{reviewer.name} on MR ##{id}\n"
  end

  # TODO: Move all these git related methods to a Git model.
  def gitlab_ci_branch_name(patch)
    patch = Patch.find(patch) if patch.is_a? Integer
    "mr-#{id}-version-#{patches.index(patch) + 1}"
  end

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

  def on_git_repository(patch)
    base_dir = "#{Dir.tmpdir}/reviewit"
    project_dir_name = "patch#{patch.id}_#{SecureRandom.hex}"
    dir = "#{base_dir}/#{project_dir_name}"
    FileUtils.rm_rf dir
    FileUtils.mkdir_p dir

    call "cd #{base_dir} && git clone --depth 1 #{project.repository} #{project_dir_name}"
    call "cd #{dir} && git reset --hard origin/#{target_branch}"
    yield dir
  ensure
    FileUtils.rm_rf dir
  end

  def git_am(dir, patch)
    contents = git_format_patch(patch)
    file = Tempfile.new 'patch'
    file.puts contents
    file.close
    call "cd #{dir} && git am #{file.path}"
  end

  def git_push(dir, branch)
    call "cd #{dir} && git push origin master:#{branch}"
  end

  def git_rm_branch(dir, branch)
    call "cd #{dir} && git push origin :#{branch}"
  end

  def git_prune_old_versions(dir, patch)
    patches = patch_ids
    patches.delete(patch.id)
    patches.each do |p|
      git_rm_branch(dir, gitlab_ci_branch_name(p))
    end
  end

  def git_hash(dir, branch = 'HEAD')
    `cd #{dir} && git rev-parse #{branch}`.strip
  end

  def output
    @output ||= StringIO.new
  end

  def call(command)
    output.puts "$ #{command}"
    res = `#{command} 2>&1`.strip
    output.puts(res) unless res.empty?
    $?.exitstatus.zero?
  end
end
