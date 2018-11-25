class LockedBranch < ActiveRecord::Base
  belongs_to :who, class_name: 'User'
  belongs_to :project
  validates :branch, presence: true, uniqueness: { scope: :project, message: 'already locked.' }
end
