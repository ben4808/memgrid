class LoginController < ApplicationController
  before_filter :set_login_info

  before_filter :verify_login_data, only: [:login, :register]
  def verify_login_data
    uname = params[:uname].strip
    if uname.empty?
      @error = "Username field empty."
      render 'index' and return
    end
    passw = params[:passw].strip
    if passw.empty?
      @error = "Password field empty."
      render 'index' and return
    end
  end

  def index
    #render plain view
  end
 
  def login
    uname = params[:uname].strip
    passw = params[:passw].strip

    user = User.where("username = '#{uname}' and password = '#{hashPassword(passw)}'")
    if (user.length == 0)
      @error = "Login incorrect."
      render 'index' and return
    end

    cookies[:uid] = user.first.id
    cookies[:uname] = user.first.username
    set_login_info
    redirect_to your_path
  end

  def register
    uname = params[:uname].strip
    passw = params[:passw].strip

    user = User.where("username = '#{uname}'")
    if (user.length != 0)
      @error = "Username already taken."
      render 'index' and return
    end

    user = User.create(username: uname, password: hashPassword(passw))
    cookies[:uid] = user.id
    cookies[:uname] = user.username
    set_login_info
    redirect_to your_path
  end

  def logout
    cookies.delete :uid
    cookies.delete :uname
    set_login_info
    redirect_to browse_path
  end

  def hashPassword(passw)
    return Digest::SHA256.hexdigest('392bukwl22' + passw)
  end
end
