require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to have_secure_password }

    it 'requires a unique email (case-insensitive)' do
      create(:user, email: 'taken@example.com')
      duplicate = build(:user, email: 'TAKEN@EXAMPLE.COM')

      expect(duplicate).not_to be_valid
    end

    it 'rejects an invalid email format' do
      expect(build(:user, email: 'not-an-email')).not_to be_valid
    end

    it 'requires a password of at least 8 characters' do
      expect(build(:user, password: 'short')).not_to be_valid
    end
  end

  describe 'role' do
    it { is_expected.to define_enum_for(:role).with_values(member: 0, admin: 1) }

    it 'defaults to member' do
      expect(User.new.role).to eq('member')
    end
  end

  describe 'email normalization' do
    it 'strips and downcases the email before validation' do
      user = create(:user, email: '  MixedCase@Example.com  ')

      expect(user.email).to eq('mixedcase@example.com')
    end
  end
end
