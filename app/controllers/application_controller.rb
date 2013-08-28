class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  def set_login_info
    if(cookies.has_key?(:uid))
      @logged_in = true
      @logged_uid = cookies[:uid]
      @logged_uname = cookies[:uname]
    else
      @logged_in = false
    end
  end

  def redirect_if_not_logged
    redirect_to '/login' if !@logged_in
  end
end
