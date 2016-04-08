require 'test_helper'

class MergeRequestMailerTest < ActionMailer::TestCase
  def setup
    Rails.application.config.action_mailer.default_url_options = { host: 'example.com' }
  end

  let(:user1)   { create(:user, name: 'Mr. Tester') }
  let(:user2)   { create(:user) }
  let(:project) { create(:project, users: [user1, user2]) }
  let(:mr) do
    mr = build(:merge_request, project: project, subject: 'Subject', author: user1)
    mr.add_patch(diff: Diff.new(patch('mailer_create_mr')),
                 linter_ok: true,
                 ci_enabled: false)
    mr.save!
    mr
  end

  def test_mr_creation
    email = MergeRequestMailer.created(mr).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [user2.email], email.to

    assert_includes email.body.to_s, 'Ruby hash function'
  end

  def test_message_id
    email1 = MergeRequestMailer.created(mr).deliver_now
    mr.add_comments(user2, mr.patch, [[0, 'Hello']])
    email2 = MergeRequestMailer.updated(user1, mr, Hash.new({})).deliver_now

    assert_equal(email1.header['Message-ID'].value,
                 email2.header['In-Reply-To'].value)
  end
end
