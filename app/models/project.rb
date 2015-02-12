class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :merge_requests, dependent: :destroy

  validates :name, presence: true
  validates :repository, presence: true

  def gitlab_ci?
    !gitlab_ci_token.blank? and !gitlab_ci_project_url.blank?
  end

  def ci_status patch
    fail if patch.gitlab_ci_hash.blank?

    Timeout.timeout(2) do
      raw_result = Net::HTTP.get(ci_status_url_for(patch))
      result = JSON.parse(raw_result)
      result['url'] = "#{gitlab_ci_project_url}/builds/#{result['id']}"
      result
    end
  rescue
    Rails.logger.error "Failed to get CI status: #{$!.message}"
    { status: 'unknown' }
  end

  private

  def ci_status_url_for patch
    URI("#{gitlab_ci_project_url}/builds/#{patch.gitlab_ci_hash}/status.json?token=#{gitlab_ci_token}")
  end
end
