class BrowseController < ApplicationController
  before_filter :set_login_info
  before_filter :redirect_if_not_logged_in, except: [:index, :search, :records]

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
    puts "hi1"
 
    query = nil
    if @query_type == 'all'
      query = List.where(:public => true).order('points desc', 'lower(name)')
    elsif @query_type == 'favorites'
      uid = User.where(username: @user).first.id
      query = List.joins(:favorites).where(favorites: {user_id: uid}).order('lower(name)')
    elsif @query_type == 'your'
      query = List.where("user_id=#{@logged_uid}").order('lower(name)')
    elsif @query_type == 'user'
      uid = User.where(username: @user).first
      if uid.nil?
	render text: 'No results'
	return
      end
      uid = uid.id
      query = List.where("user_id=#{uid}").where(:public => true).order('lower(name)')
    elsif @query_type == 'search'
      query = List.where("name like '%#{@keyword}%'").where(:public => true).order('points desc', 'lower(name)')
    end

    puts "hi2"
    @total = query.count
    query = query.limit(10).offset(@offset)
    @count = @offset + query.count
    @lists = make_list_records(query)

    puts "hi2"
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
    list = List.find(id)
    list.name = params[:edit_list_name].strip
    list.public = !params[:edit_list_public].nil?
    list.description = params[:edit_list_desc].strip
    list.save unless list.name.empty? || list.description.empty?
    redirect_to your_path
  end

  def edit_list
    id = params[:id]
    @list = List.find(id)
    render layout: false
  end

  def delete
    id = params[:id]
    List.where(:id => id).destroy_all
    redirect_to your_path
  end

  def vote
    id = params[:id]
    is_up = params[:dir] == 'up'
    list = List.find(id)
    cur_vote = ListVote.where(user_id: @logged_uid, list_id: id).first
    if(cur_vote.nil?)
      ListVote.create(user_id: @logged_uid, list_id: id, is_up: is_up)
      list.points += (is_up ? 1 : -1)
    elsif(cur_vote.is_up != is_up)
      cur_vote.destroy
      list.points += (is_up ? 1 : -1)
    end
    list.save
    render nothing: true
  end

  def make_list_records (res)
    ret = []
    res.each do |list|
      words = list.words
      first_words = []
      3.times { |i| first_words << words[i].word if words[i] }
      puts first_words.to_s
      vote_res = @logged_in ? ListVote.where("user_id=#{@logged_uid} and list_id=#{list.id}").first : nil
      vote = vote_res.nil? ? 0 : (vote_res.is_up ? 1 : -1)
      ret << ListRecord.new(list.id, list.name, list.description, list.points, list.user.username, words.count, first_words, vote)
    end
    ret
  end
end

class ListRecord
  attr_accessor :id, :name, :description, :points, :author, :count, :first_words, :vote
  
  def initialize (id, name, description, points, author, count, first_words, vote)
    @id = id; @name = name; @description = description; @points = points; @points = points
    @author = author; @count = count; @first_words = first_words; @vote = vote
  end
end
