class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :patch

  scope :general, -> { where(location: 0) }
  scope :code, -> { where.not(location: 0) }
end
