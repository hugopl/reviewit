class LockedBranch < ApplicationRecord
  belongs_to :who, class_name: 'User'
  belongs_to :project
  validates :branch, presence: true, uniqueness: { scope: :project, message: 'already locked.' }
end
