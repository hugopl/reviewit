require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_required_name
    user = build(:user, name: nil)
    user.wont_be :valid?
  end

  def test_required_email
    user = build(:user, email: nil)
    user.wont_be :valid?
  end

  def test_required_valid_email
    user = build(:user, email: 'invalid')
    user.wont_be :valid?

    emails = %w(john@example.org
                john@example.com.br
                john@example.co.uk
                john123@example.com
                john.doe@example.com
                john+spam@example.com
                john@example.io
                john@example.info
                john@example-domain.com
                barros_filho_washington@silva.br)
    emails.each do |email|
      user = build(:user, email: email)
      user.must_be :valid?, "email #{email} not accepted!?"
    end
  end

  def test_email_uniqueness
    user1 = create(:user)
    user2 = build(:user, email: user1.email)
    user2.wont_be :valid?
  end
end
