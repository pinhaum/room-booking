require "rails_helper"

RSpec.describe RoomCreator do
  describe ".call" do
    it "creates a room with valid attributes" do
      expect {
        RoomCreator.call(name: "Nova Sala", capacity: 8)
      }.to change(Room, :count).by(1)
    end

    it "raises InvalidRoom carrying the invalid record" do
      expect {
        RoomCreator.call(name: "", capacity: 8)
      }.to raise_error(RoomCreator::InvalidRoom) do |error|
        expect(error.room.errors[:name]).to be_present
      end
    end
  end
end
