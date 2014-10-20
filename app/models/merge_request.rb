require 'tmpdir'
require 'fileutils'
require 'tempfile'

class MergeRequest < ActiveRecord::Base
  belongs_to :author, class_name: User
  belongs_to :reviewer, class_name: User
  belongs_to :project

  has_many :patches, dependent: :destroy

  enum status: [ :open, :integrating, :needs_rebase, :accepted, :abandoned ]

  # Any status >= this is considered a closed MR
  CLOSE_LIMIT = 3

  scope :pending, -> { where("status < #{CLOSE_LIMIT}") }
  scope :closed, -> { where("status >= #{CLOSE_LIMIT}") }

  validates :target_branch, presence: true
  validates :subject, presence: true
  validates :commit_message, presence: true

  def closed?
    MergeRequest.statuses[status] >= CLOSE_LIMIT
  end

  def integrate! reviewer
    self.reviewer = reviewer
    self.status = :integrating
    save!

    Thread.new do
      patch = patches.newer.reload
      prepare_git_repository(patch)
      if git_am(patch) and git_push
        reload.accepted!
      else
        reload.needs_rebase!
      end
      patch.integration_log = @output.string
      patch.save
    end
  end

  def patch
    patches.newer
  end

  def git_format_patch
    reviewer_stamp = (reviewer.nil? ? '' : "\nReviewed by #{reviewer.name} on MR ##{id}\n\n")
    out =<<eot
From: #{author.name} #{author.email}
Date: #{patch.created_at.strftime('%a, %d %b %Y %H:%M:%S %z')}

#{commit_message}
#{reviewer_stamp}
#{patch.diff}
--
review it!
eot
  end

private

  def prepare_git_repository patch
    base_dir = "#{Dir.tmpdir}/reviewit/project#{project_id}"
    project_dir_name = "patch#{patch.id}"
    @dir = "#{base_dir}/#{project_dir_name}"
    FileUtils.rm_rf @dir
    FileUtils.mkdir_p @dir

    call "cd #{base_dir} && git clone --depth 1 #{project.repository} #{project_dir_name}"
    call "cd #{@dir} && git reset --hard origin/#{target_branch}"
  end

  def git_am patch
    contents = git_format_patch(patch)
    file = Tempfile.new 'patch'
    file.puts contents
    file.close
    call "cd #{@dir} && git am #{file.path}"
  end

  def git_push
    call "cd #{@dir} && git push origin #{target_branch}"
  end

  def call command
    @output ||= StringIO.new
    @output.puts "$ #{command}"
    output = `#{command} 2>&1`.strip
    @output.puts output unless output.empty?
    $?.exitstatus == 0
  end
end
