class Patch < ActiveRecord::Base
  belongs_to :merge_request

  has_many :comments, dependent: :destroy

  enum gitlab_ci_status: %i(unknown failed pass)

  order :location

  validates :diff, presence: true
  validates :commit_message, presence: true

  after_create :push_to_ci

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

  private

  def push_to_ci
    merge_request.push_to_gitlab_ci(self) if gitlab_ci_hash.blank?
  end
end
