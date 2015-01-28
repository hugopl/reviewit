class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :patch

  scope :root, -> { where(location: 0) }
end
