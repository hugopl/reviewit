class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :projects

  before_create :generate_api_token

  validates :name, presence: true, allow_blank: false

  def self.valid_token?(token)
    User.exists?(api_token: token)
  end

  def self.all_names
    User.all.map(&:name)
  end

  private

  def generate_api_token
    loop do
      self.api_token = SecureRandom.urlsafe_base64
      break unless User.exists?(api_token: api_token)
    end
  end
end
