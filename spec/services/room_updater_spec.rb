require "rails_helper"

RSpec.describe RoomUpdater do
  let(:room) { create(:room, capacity: 10) }

  describe ".call" do
    it "updates the room with valid attributes" do
      RoomUpdater.call(room, capacity: 25)

      expect(room.reload.capacity).to eq(25)
    end

    it "raises InvalidRoom on invalid attributes" do
      expect {
        RoomUpdater.call(room, capacity: 0)
      }.to raise_error(RoomUpdater::InvalidRoom)
      expect(room.reload.capacity).to eq(10)
    end
  end
end
