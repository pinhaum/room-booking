# Base policy: deny-by-default. Resources subclass this and open actions explicitly.
# Authorization combines role (admin?) and ownership (owner?) — see ADR-006.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  # Scope: deny-by-default (empty). Resources override #resolve.
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.none
    end
  end

  private

  def admin?
    user&.admin? || false
  end

  def owner?
    record.respond_to?(:user) && record.user == user
  end
end
