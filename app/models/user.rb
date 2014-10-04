class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :projects

  before_create :generate_api_token

  def self.valid_token? token
    User.exists?(api_token: token)
  end

private
  def generate_api_token
    loop do
      self.api_token = SecureRandom.urlsafe_base64
      break unless User.exists?(api_token: self.api_token)
    end
  end
end
