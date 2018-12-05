class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :reviewer, class_name: 'User'
  belongs_to :patch

  delegate :merge_request, to: :patch

  enum status: %i(blocker solved)

  default_scope { order(:created_at) }
  scope :general, -> { where(location: 0) }
  scope :code, -> { where.not(location: 0) }
end
