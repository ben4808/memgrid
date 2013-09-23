class HomeController < ApplicationController
  before_filter :redirect_if_logged_in

  def index
    #render default view
  end
end
