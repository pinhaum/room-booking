# Rooms are readable by any authenticated user; only admins may manage them (ADR-006).
class RoomPolicy < ApplicationPolicy
  def index? = true
  def show? = true
  def create? = admin?
  def update? = admin?
  def destroy? = admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
