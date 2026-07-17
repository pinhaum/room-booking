require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:password) { 'password123' }
  let!(:user) { create(:user, email: 'person@example.com', password: password) }

  describe 'GET /login' do
    it 'renders the login form' do
      get login_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /login' do
    it 'signs in with valid credentials and sets the session' do
      post login_path, params: { email: 'person@example.com', password: password }

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(user.id)
    end

    it 'is case-insensitive on the email' do
      post login_path, params: { email: 'PERSON@EXAMPLE.COM', password: password }

      expect(session[:user_id]).to eq(user.id)
    end

    it 're-renders with 422 and no session on invalid credentials' do
      post login_path, params: { email: 'person@example.com', password: 'wrong' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(session[:user_id]).to be_nil
    end
  end

  describe 'DELETE /logout' do
    it 'clears the session' do
      post login_path, params: { email: 'person@example.com', password: password }
      delete logout_path

      expect(response).to redirect_to(login_path)
      expect(session[:user_id]).to be_nil
    end
  end
end
