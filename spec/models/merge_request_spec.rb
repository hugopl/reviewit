describe MergeRequest do
  let(:user) { create(:user) }
  let(:mr)   { create(:merge_request) }
  let(:mr2)  { create(:merge_request) }

  it 'do reset likes from a merge request after a patch being added to it' do
    mr2.likes.create(user: user)
    mr.likes.create(user: user)
    expect(mr.likes.count).to eq(1)
    expect(mr2.likes.count).to eq(1)

    create(:patch, merge_request: mr)
    expect(mr.likes.count).to eq(0)
    expect(mr2.likes.count).to eq(1)
  end

  it 'forbid more than one like per merge request' do
    mr.likes.create(user: user)
    like = mr.likes.build(user: user)
    expect(like.save).to eq(false)
  end
end
