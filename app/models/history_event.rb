class HistoryEvent < ActiveRecord::Base
  belongs_to :who, class_name: User

  validates :who, presence: true
  validates :what, presence: true
end
