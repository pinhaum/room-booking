require "rails_helper"

RSpec.describe RoomDestroyer do
  describe ".call" do
    it "destroys the room" do
      room = create(:room)

      expect {
        RoomDestroyer.call(room)
      }.to change(Room, :count).by(-1)
    end
  end
end
