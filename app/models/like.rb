class Like < ApplicationRecord
  belongs_to :merge_request
  belongs_to :user

  validates :user_id, uniqueness: { scope: :merge_request_id }
end
