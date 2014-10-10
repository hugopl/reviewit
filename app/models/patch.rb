class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments
  scope :newer, -> { order(:updated_at).reverse_order.first }
end
