require 'test_helper'

class MergeRequestMailerTest < ActionMailer::TestCase
  test 'create MR' do
    Rails.application.config.action_mailer.default_url_options = { host: 'example.com' }

    user1 = create(:user, name: 'Mr. Tester')
    user2 = create(:user)
    project = create(:project, users: [user1, user2])

    mr = build(:merge_request, project: project, subject: 'Subject', author: user1)
    mr.add_patch(
      commit_message: "Subject\n\nI'm a markdown _message_.",
      diff: 'a diff',
      linter_ok: true)
    mr.save

    email = MergeRequestMailer.created(mr).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [user2.email], email.to

    assert_includes email.body.to_s, '<em>message</em>'

    File.open('/tmp/foo.html', 'w') do |f| f.puts(email.body.to_s) end
  end
end
