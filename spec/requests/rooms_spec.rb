require "rails_helper"

RSpec.describe "Rooms", type: :request do
  let(:member) { create(:user) }
  let(:admin)  { create(:user, :admin) }

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password123" }
  end

  describe "authentication" do
    it "redirects anonymous users to login" do
      get rooms_path

      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET /rooms" do
    before { sign_in_as(member) }

    it "lists rooms and applies filters" do
      create(:room, name: "Sala Grande", capacity: 30)
      create(:room, name: "Sala Pequena", capacity: 4)

      get rooms_path, params: { min_capacity: 10 }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sala Grande")
      expect(response.body).not_to include("Sala Pequena")
    end
  end

  describe "POST /rooms" do
    context "as member" do
      before { sign_in_as(member) }

      it "is forbidden" do
        expect {
          post rooms_path, params: { room: { name: "X", capacity: 5 } }
        }.not_to change(Room, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "as admin" do
      before { sign_in_as(admin) }

      it "creates a room" do
        expect {
          post rooms_path, params: { room: { name: "Sala Nova", capacity: 5 } }
        }.to change(Room, :count).by(1)
        expect(response).to redirect_to(room_path(Room.last))
      end

      it "re-renders with 422 on invalid attributes" do
        post rooms_path, params: { room: { name: "", capacity: 5 } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /rooms/:id" do
    let!(:room) { create(:room) }

    it "is forbidden for members" do
      sign_in_as(member)

      expect {
        delete room_path(room)
      }.not_to change(Room, :count)
      expect(response).to have_http_status(:forbidden)
    end

    it "removes the room for admins" do
      sign_in_as(admin)

      expect {
        delete room_path(room)
      }.to change(Room, :count).by(-1)
      expect(response).to redirect_to(rooms_path)
    end
  end
end
