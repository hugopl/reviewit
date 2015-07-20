class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :merge_requests, dependent: :destroy

  validates :name, presence: true
  validate :validate_repository

  def gitlab_ci?
    !gitlab_ci_token.blank? and !gitlab_ci_project_url.blank?
  end

  def ci_status(patch)
    fail if patch.gitlab_ci_hash.blank?

    Timeout.timeout(2) do
      raw_result = Net::HTTP.get(ci_status_url_for(patch))
      result = JSON.parse(raw_result)
      result['url'] = "#{gitlab_ci_project_url}/builds/#{result['id']}"

      cache_status(patch, result['status']) unless patch.pass?
      result
    end
  rescue
    { status: 'unknown' }
  end

  private

  def ci_status_url_for(patch)
    URI("#{gitlab_ci_project_url}/builds/#{patch.gitlab_ci_hash}/status.json?token=#{gitlab_ci_token}")
  end

  def cache_status(patch, status)
    case status
    when 'success' then patch.pass!
    when 'failed' then patch.failed!
    when 'canceled' then patch.canceled!
    end
  end

  def validate_repository
    is_valid = URI.regexp =~ repository && /\A[^ ;&|]+\z/ =~ repository
    errors.add(:repository, 'is not a valid URI') unless is_valid
  end
end
