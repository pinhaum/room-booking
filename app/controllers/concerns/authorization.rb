module Authorization
  extend ActiveSupport::Concern

  class NotAuthorized < StandardError; end

  included do
    rescue_from Authorization::NotAuthorized, with: :user_not_authorized
  end

  private

  # Authorizes the current action against the record's policy.
  # Returns the record when allowed; raises NotAuthorized otherwise (ADR-009).
  def authorize(record, query = nil)
    query ||= "#{action_name}?"
    raise NotAuthorized unless policy(record).public_send(query)

    record
  end

  def policy(record)
    "#{record.class}Policy".constantize.new(current_user, record)
  end

  def policy_scope(scope)
    klass = scope.respond_to?(:klass) ? scope.klass : scope
    "#{klass}Policy".constantize::Scope.new(current_user, scope).resolve
  end

  def user_not_authorized
    respond_to do |format|
      format.html { render plain: I18n.t("authorization.not_authorized"), status: :forbidden }
      format.json { head :forbidden }
    end
  end
end
