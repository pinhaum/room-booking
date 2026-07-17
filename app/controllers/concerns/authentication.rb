module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  private

  def current_user
    Current.user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    return if logged_in?

    respond_to do |format|
      format.html { redirect_to login_path, alert: I18n.t("auth.login_required") }
      format.json { head :unauthorized }
    end
  end

  def sign_in(user)
    reset_session
    Current.user = user
    session[:user_id] = user.id
  end

  def sign_out
    reset_session
    Current.user = nil
  end
end
