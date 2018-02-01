class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :merge_requests, dependent: :destroy

  validates :name, presence: true
  validates :linter, format: { with: %r{\A[^\./](?!.*(\.\.|[&|<>])).*\z},
                               message: "can't have pipes, dots, slashes, two dots, etc, try to use a script in your " \
                                        'project directory' },
                     allow_blank: true
  validate :validate_repository

  def gitlab_ci?
    !gitlab_ci_project_url.blank?
  end

  def configuration_hash
    Digest::MD5.hexdigest(linter)
  end

  private

  def validate_repository
    is_valid = URI::DEFAULT_PARSER.make_regexp =~ repository && /\A[^ ;&|]+\z/ =~ repository
    errors.add(:repository, 'is not a valid URI') unless is_valid
  end
end
