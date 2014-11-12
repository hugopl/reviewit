require 'tmpdir'
require 'fileutils'
require 'tempfile'

class MergeRequest < ActiveRecord::Base
  belongs_to :author, class_name: User
  belongs_to :reviewer, class_name: User
  belongs_to :project

  has_many :patches, -> { order(:created_at) }, dependent: :destroy

  enum status: [ :open, :integrating, :needs_rebase, :accepted, :abandoned ]

  # Any status >= this is considered a closed MR
  CLOSE_LIMIT = 3

  scope :pending, -> { where("status < #{CLOSE_LIMIT}") }
  scope :closed, -> { where("status >= #{CLOSE_LIMIT}") }

  validates :target_branch, presence: true
  validates :subject, presence: true
  validates :author, presence: true
  validate :author_cant_be_reviewer

  def can_update?
    not %w(accepted integrating).include? status
  end

  def closed?
    MergeRequest.statuses[status] >= CLOSE_LIMIT
  end

  def abandon! reviewer
    self.reviewer = reviewer
    self.status = :abandoned
    save!
  end

  def integrate! reviewer
    return if status == :accepted or status == :integrating
    self.reviewer = reviewer
    self.status = :integrating
    save!

    Thread.new do
      begin
        prepare_git_repository(patch)
        if git_am(patch) and git_push
          reload.accepted!
        else
          reload.needs_rebase!
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

  def patch
    @patch ||= patches.last
  end

  def git_format_patch
    reviewer_stamp = (reviewer.nil? ? '' : "\nReviewed by #{reviewer.name} on MR ##{id}\n\n")
    out =<<eot
From: #{author.name} #{author.email}
Date: #{patch.created_at.strftime('%a, %d %b %Y %H:%M:%S %z')}

#{patch.commit_message}
#{reviewer_stamp}
#{patch.diff}
--
review it!
eot
  end

private

  def author_cant_be_reviewer
    errors.add(:reviewer, 'can\'t be the author.') if author == reviewer
  end

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
    contents = git_format_patch
    file = Tempfile.new 'patch'
    file.puts contents
    file.close
    call "cd #{@dir} && git am #{file.path}"
  end

  def git_push
    call "cd #{@dir} && git push origin #{target_branch}"
  end

  def output
    @output ||= StringIO.new
  end

  def call command
    output.puts "$ #{command}"
    res = `#{command} 2>&1`.strip
    output.puts(res) unless res.empty?
    $?.exitstatus == 0
  end
end
