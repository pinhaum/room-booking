class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = UserAuthenticator.call(email: params[:email], password: params[:password])
    sign_in(user)
    redirect_to root_path, notice: I18n.t("auth.signed_in")
  rescue UserAuthenticator::InvalidCredentials
    flash.now[:alert] = I18n.t("auth.invalid_credentials")
    render :new, status: :unprocessable_entity
  end

  def destroy
    sign_out
    redirect_to login_path, notice: I18n.t("auth.signed_out")
  end
end
