class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :projects

  before_create :generate_api_token
  has_many :comments
  has_many :merge_requests, foreign_key: :author_id

  validates :name, presence: true, allow_blank: false
  validates :api_token, uniqueness: true

  scope(:webpush_enabled, lambda do
    where('webpush_endpoint IS NOT NULL AND webpush_p256dh IS NOT NULL AND webpush_auth IS NOT NULL')
  end)

  WEBPUSH_TTL = 8.hours.to_i

  def self.valid_token?(token)
    User.exists?(api_token: token)
  end

  def self.all_names
    User.all.map(&:name)
  end

  def email_address
    "#{name} <#{email}>"
  end

  def webpush_notification_enabled?
    webpush_endpoint.present? && webpush_p256dh.present? && webpush_auth.present?
  end

  def self.send_webpush(users, title, body, url = '/')
    users.each do |user|
      user.send_webpush_assync(title, body, url)
    end
  end

  def send_webpush_assync(title, body, url = '/')
    return unless webpush_notification_enabled?

    Thread.new do
      begin
        send_webpush(title, body, url)
      ensure
        ActiveRecord::Base.connection.close
      end
    end
  end

  def send_webpush(title, body, url = '/')
    return unless webpush_notification_enabled?

    Webpush.payload_send(
      message: { title: title, body: body, tag: 'reviewit', url: url }.to_json,
      endpoint: webpush_endpoint,
      p256dh: webpush_p256dh,
      auth: webpush_auth,
      ttl: WEBPUSH_TTL,
      vapid: {
        subject: "mailto:#{ReviewitConfig.mail.sender}",
        public_key: ReviewitConfig.webpush_public_key,
        private_key: ReviewitConfig.webpush_private_key
      }
    )
  rescue Webpush::InvalidSubscription
    update_attributes(webpush_endpoint: nil, webpush_p256dh: nil, webpush_auth: nil)
  end

  private

  def generate_api_token
    loop do
      self.api_token = SecureRandom.urlsafe_base64
      break unless User.exists?(api_token: api_token)
    end
  end
end
