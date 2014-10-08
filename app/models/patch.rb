class Patch < ActiveRecord::Base
  belongs_to :merge_request

  scope :newer, -> { order(:updated_at).reverse_order.first }
end
