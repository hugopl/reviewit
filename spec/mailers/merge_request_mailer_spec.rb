describe MergeRequestMailer do
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

  it 'sends an email upon MR creation' do
    email = MergeRequestMailer.created(mr).deliver_now
    expect(email.to).to eq([user2.email])

    expect(email.body).to include('Ruby hash function')
  end

  it 'sends emails from same MR in the same thread' do
    email1 = MergeRequestMailer.created(mr).deliver_now
    mr.add_comments(user2, mr.patch, [[0, 'Hello']], [])
    email2 = MergeRequestMailer.updated(user1, mr, Hash.new({})).deliver_now

    assert_equal(email1.header['Message-ID'].value,
                 email2.header['In-Reply-To'].value)
  end
end
