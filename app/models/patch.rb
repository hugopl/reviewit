class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments, dependent: :destroy
  scope :newer, -> { order(:updated_at).reverse_order.first }

  order :location

  def comment
    @comment ||= (self.comments.find_by_location(0) or Comment.new)
  end

  def comments_by_location
    comments.order(:location).to_a.inject({}) do |hash, comment|
      location = comment.location.to_i
      unless location.zero?
        hash[location] ||= []
        hash[location] << comment
      end
      hash
    end
  end
end
