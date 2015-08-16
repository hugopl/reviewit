require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'name required' do
    user = build(:user, name: nil)
    assert_not(user.valid?)
  end

  test 'email required' do
    user = build(:user, email: nil)
    assert_not user.valid?
  end

  test 'valid email required' do
    user = build(:user, email: 'invalid')
    assert_not(user.valid?)

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
      assert(user.valid?, "email #{email} not accepted!?")
    end
  end

  test 'email uniqueness' do
    user1 = create(:user)
    user2 = build(:user, email: user1.email)
    assert_not(user2.valid?)
  end
end
