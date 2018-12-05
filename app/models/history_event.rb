class HistoryEvent < ApplicationRecord
  belongs_to :who, class_name: 'User'

  validates :who, presence: true
  validates :what, presence: true

  before_create :add_when_value

  private

  def add_when_value
    self.when = Time.now
  end
end
