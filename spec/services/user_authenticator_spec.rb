require 'rails_helper'

RSpec.describe UserAuthenticator do
  let(:password) { 'password123' }
  let!(:user) { create(:user, email: 'person@example.com', password: password) }

  it 'returns the user for valid credentials' do
    result = described_class.call(email: 'person@example.com', password: password)

    expect(result).to eq(user)
  end

  it 'authenticates regardless of email case and surrounding whitespace' do
    result = described_class.call(email: '  PERSON@EXAMPLE.COM  ', password: password)

    expect(result).to eq(user)
  end

  it 'raises InvalidCredentials for a wrong password' do
    expect do
      described_class.call(email: 'person@example.com', password: 'wrong-password')
    end.to raise_error(UserAuthenticator::InvalidCredentials)
  end

  it 'raises InvalidCredentials for an unknown email' do
    expect do
      described_class.call(email: 'nobody@example.com', password: password)
    end.to raise_error(UserAuthenticator::InvalidCredentials)
  end
end
