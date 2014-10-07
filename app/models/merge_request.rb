class MergeRequest < ActiveRecord::Base
  belongs_to :owner, class_name: User
  belongs_to :reviewer, class_name: User
  belongs_to :project

  has_many :patches

  enum status: [ :open, :waiting, :closed ]
end
