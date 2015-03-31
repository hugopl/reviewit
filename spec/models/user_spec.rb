describe User do
  context 'validations' do
    it 'requires name' do
      user = User.create(name: nil)
      expect(user.errors[:name].size).to eq(1)
    end

    it 'requires email' do
      user = User.create(email: nil)
      expect(user.errors[:email].size).to eq(1)
    end

    it 'requires valid email' do
      user = User.create(email: 'invalid')
      expect(user.errors[:email].size).to eq(1)
    end

    %w(
      john@example.org
      john@example.com.br
      john@example.co.uk
      john123@example.com
      john.doe@example.com
      john+spam@example.com
      john@example.io
      john@example.info
      john@example-domain.com
      barros_filho_washington@silva.br
    ).each do |email|
      it "accepts valid email - #{email}" do
        user = User.create(email: email)
        expect(user.errors[:email].size).to eq(0)
      end
    end

    it 'requires unique email' do
      existing = User.create

      user = User.create(email: existing.email)
      expect(user.errors[:email].size).to eq(1)
    end

    it 'requires password to have at least 8 characters' do
      user = User.create(password: '1' * 7)
      expect(user.errors[:password].size).to eq(1)
    end

    it 'requires password confirmation' do
      user = User.create(
        password: 'test',
        password_confirmation: 'invalid'
      )

      expect(user.errors[:password_confirmation].size).to eq(1)
    end
  end
end
