class MergeRequest < ActiveRecord::Base
  belongs_to :owner, class_name: User
  belongs_to :reviewer, class_name: User
  belongs_to :project

  has_many :patches

  enum status: [ :open, :needs_rebase, :accepted, :abandoned ]

  scope :pending, -> { where('status < 2') }
  scope :closed, -> { where('status >= 2') }

  validates :target_branch, presence: true

  def closed?
    MergeRequest.statuses[status] >= 2
  end
end
