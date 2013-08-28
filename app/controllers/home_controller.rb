class HomeController < ApplicationController
  before_filter :set_login_info
  before_filter :redirect_if_not_logged

  before_filter :verify_list_data, only: [:new]
  def verify_list_data
    name = params[:name].strip
    if name.empty?
      redirect_to '/' and return
    end
  end

  def index
    @list_names = {}
    @list_counts = {}
    lists = List.where("user_id=#{@logged_uid}").order('name')
    lists.each do |list|
      @list_names[list.id] = list.name
      count = ListWord.where(:list_id => list.id).count
      @list_counts[list.id] = count
    end
  end

  def new
    name = params[:name].strip 
    List.create(user_id: @logged_uid, name: name)
    redirect_to '/'
  end

  def edit
    id = params[:id]
    list = List.where(:id => id).first
    list.name = params[:name]
    list.save
    redirect_to '/'
  end

  def delete
    id = params[:id]
    List.where(:id => id).destroy_all
    redirect_to '/'
  end
end
