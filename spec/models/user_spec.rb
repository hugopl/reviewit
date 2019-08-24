describe 'User' do
  it 'requires a name' do
    user = build(:user, name: nil)
    expect(user).not_to be_valid
  end

  it 'requires a email' do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
  end

  it 'requires a valid email' do
    user = build(:user, email: 'invalid')
    expect(user).not_to be_valid

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
      expect(user).to be_valid
    end
  end

  it 'requires a unique email' do
    user1 = create(:user)
    user2 = build(:user, email: user1.email)
    expect(user2).not_to be_valid
  end
end
