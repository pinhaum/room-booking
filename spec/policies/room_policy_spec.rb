require "rails_helper"

RSpec.describe RoomPolicy do
  let(:room)   { build_stubbed(:room) }
  let(:member) { build_stubbed(:user) }
  let(:admin)  { build_stubbed(:user, :admin) }

  describe "reading" do
    it "allows any authenticated user to index and show" do
      policy = RoomPolicy.new(member, room)

      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
    end
  end

  describe "writing" do
    it "denies members" do
      policy = RoomPolicy.new(member, room)

      expect(policy.create?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
    end

    it "allows admins" do
      policy = RoomPolicy.new(admin, room)

      expect(policy.create?).to be(true)
      expect(policy.update?).to be(true)
      expect(policy.destroy?).to be(true)
    end
  end

  describe RoomPolicy::Scope do
    it "returns all rooms" do
      create_list(:room, 2)

      resolved = RoomPolicy::Scope.new(member, Room).resolve

      expect(resolved).to match_array(Room.all)
    end
  end
end
