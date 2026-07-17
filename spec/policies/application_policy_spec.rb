require 'rails_helper'

RSpec.describe ApplicationPolicy do
  let(:user) { build_stubbed(:user) }
  let(:record) { Object.new }

  subject(:policy) { described_class.new(user, record) }

  it 'denies every action by default' do
    aggregate_failures do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
      expect(policy.create?).to be(false)
      expect(policy.new?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.edit?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end

  describe '#admin?' do
    it 'is true for an admin user and false otherwise' do
      admin = build_stubbed(:user, role: :admin)

      expect(described_class.new(admin, record).send(:admin?)).to be(true)
      expect(described_class.new(user, record).send(:admin?)).to be(false)
    end
  end

  describe '#owner?' do
    let(:record) { Struct.new(:user).new(user) }

    it 'is true when the record belongs to the user' do
      expect(policy.send(:owner?)).to be(true)
    end

    it 'is false for a different user' do
      expect(described_class.new(build_stubbed(:user), record).send(:owner?)).to be(false)
    end
  end

  describe ApplicationPolicy::Scope do
    it 'resolves to an empty scope by default' do
      scope = instance_double(ActiveRecord::Relation, none: :empty)

      expect(described_class.new(user, scope).resolve).to eq(:empty)
    end
  end
end
