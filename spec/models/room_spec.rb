require "rails_helper"

RSpec.describe Room, type: :model do
  subject { build(:room) }

  it { is_expected.to be_valid }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_numericality_of(:capacity).only_integer.is_greater_than(0) }
  end

  describe "normalization" do
    it "strips surrounding whitespace from the name" do
      room = create(:room, name: "  Sala X  ")

      expect(room.name).to eq("Sala X")
    end
  end

  describe "scopes" do
    let!(:small)       { create(:room, name: "Reuniao", capacity: 4, available: true) }
    let!(:large)       { create(:room, name: "Auditorio", capacity: 40, available: true) }
    let!(:unavailable) { create(:room, name: "Deposito", capacity: 20, available: false) }

    it ".available returns only available rooms" do
      expect(Room.available).to contain_exactly(small, large)
    end

    it ".with_min_capacity filters by minimum capacity" do
      expect(Room.with_min_capacity(20)).to contain_exactly(large, unavailable)
    end

    it ".search_by_name matches case-insensitively" do
      expect(Room.search_by_name("audit")).to contain_exactly(large)
    end
  end

  describe ".filter_by" do
    let!(:small)       { create(:room, name: "Sala Pequena", capacity: 4, available: true) }
    let!(:big)         { create(:room, name: "Sala Grande", capacity: 30, available: true) }
    let!(:unavailable) { create(:room, name: "Sala Fechada", capacity: 30, available: false) }

    it "returns all rooms when no filters are given" do
      expect(Room.filter_by({})).to contain_exactly(small, big, unavailable)
    end

    it "combines available and capacity filters" do
      expect(Room.filter_by(available: "true", min_capacity: 10)).to contain_exactly(big)
    end

    it "filters by name" do
      expect(Room.filter_by(name: "grande")).to contain_exactly(big)
    end
  end
end
