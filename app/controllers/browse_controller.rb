class BrowseController < ApplicationController
  before_filter :set_login_info
  before_filter :redirect_if_not_logged_in

  before_filter :setup_list_vars, only: [:index, :favorites, :your, :user]
  def setup_list_vars
    @user = @logged_uname
    @keyword = ''
  end

  def index
    @heading = "Public Lists"
    @query_type = 'all'
  end

  def favorites
    @heading = "Favorites"
    @query_type = 'favorites'
    render :index
  end

  def your
    @heading = "Your Lists"
    @query_type = 'your'
    render :index
  end

  def user
    @user = params[:user]
    @heading = "#{@user}'s Lists"
    @query_type = 'user'
    render :index
  end

  def search
    @keyword = params[:keyword]
    @heading = "Search: #{@keyword}"
    @query_type = "search"
    render :index
  end

  def records
    count = (params[:count] || 10).to_i
    @offset = (params[:offset] || 0).to_i
    @query_type = params[:type] || 'all'
    @user = params[:user] || @logged_uname
    @keyword = params[:keyword] || ''
 
    query = nil
    if @query_type == 'all'
      query = List.where(:public => true).order('points desc', 'lower(name)')
    elsif @query_type == 'favorites'
      uid = User.where(username: @user).first.id
      query = List.joins(:favorites).where(favorites: {user_id: uid}).order('lower(name)')
    elsif @query_type == 'your'
      query = List.where("user_id=#{@logged_uid}").order('lower(name)')
    elsif @query_type == 'user'
      uid = User.where(username: @user).first.id
      query = List.where("user_id=#{uid}").where(:public => true).order('lower(name)')
    elsif @query_type == 'search'
      query = List.where("name like '%#{@keyword}%'").where(:public => true).order('points desc', 'lower(name)')
    end

    @total = query.count
    query = query.limit(10).offset(@offset)
    @count = @offset + query.count
    @lists = make_list_records(query)

    render layout: false
  end
  
  def new
    name = params[:new_list_name].strip
    desc = params[:new_list_desc].strip
    public_ = !params[:new_list_public].nil?

    flash[:notice] = "Must specify a list name" if name.length == 0
    flash[:notice] = "List name already exists" if List.where(name: name).count > 0
    List.create(user_id: @logged_uid, name: name, points: 0, description: desc, :public => public_) if !flash[:notice]
 
    redirect_to your_path
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

  def make_list_records (res)
    ret = []
    res.each do |list|
      words = list.words
      first_words = []
      3.times { |i| first_words << words[i].word if words[i] }
      puts first_words.to_s
      ret << ListRecord.new(list.id, list.name, list.description, list.points, list.user.username, words.count, first_words)
    end
    ret
  end
end

class ListRecord
  attr_accessor :id, :name, :description, :points, :author, :count, :first_words
  
  def initialize (id, name, description, points, author, count, first_words)
    @id = id; @name = name; @description = description; @points = points; @points = points
    @author = author; @count = count; @first_words = first_words
  end
end
