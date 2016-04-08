require 'test_helper'

class MergeRequestMailerTest < ActionMailer::TestCase
  def test_mr_creation
    Rails.application.config.action_mailer.default_url_options = { host: 'example.com' }

    user1 = create(:user, name: 'Mr. Tester')
    user2 = create(:user)
    project = create(:project, users: [user1, user2])

    mr = build(:merge_request, project: project, subject: 'Subject', author: user1)
    mr.add_patch(
      diff: Diff.new(patch('mailer_create_mr')),
      linter_ok: true,
      ci_enabled: false)
    mr.save

    email = MergeRequestMailer.created(mr).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [user2.email], email.to

    assert_includes email.body.to_s, 'Ruby hash function'
  end
end
