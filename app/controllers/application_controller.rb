class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_filter :set_login_info
  def set_login_info
    if(cookies.has_key?(:uid))
      @logged_in = true
      @logged_uid = cookies[:uid]
      @logged_uname = cookies[:uname]
    else
      @logged_in = false
      @logged_uid = 0
      @logged_uname = ''
    end
  end

  def redirect_if_logged_in
    redirect_to your_path if @logged_in
  end

  def redirect_if_not_logged_in
    redirect_to login_path if !@logged_in
  end
end
