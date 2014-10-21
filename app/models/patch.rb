class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments, dependent: :destroy

  order :location

  validates :diff, presence: true
  validates :commit_message, presence: true

  def comments_by_location
    comments.to_a.inject({}) do |hash, comment|
      location = comment.location.to_i
      unless location.zero?
        hash[location] ||= []
        hash[location] << comment
      end
      hash
    end
  end
end
