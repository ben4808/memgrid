require_relative 'browse_controller.rb'

class ListController < ApplicationController
  before_filter :set_login_info

  before_filter :verify_word_data, only: [:new]
  def verify_word_data
    word = params[:word].strip
    if word.empty?
      redirect_to '/' and return
    end
  end

  require 'nokogiri'
  require 'open-uri'

  def index
    id = params[:id]
    list = List.find(id)
    list_words = list.list_words.includes(:word, :listword_defs)
    vote_res = @logged_in ? ListVote.where("user_id=#{@logged_uid} and list_id=#{list.id}").first : nil
    vote = vote_res.nil? ? 0 : (vote_res.is_up ? 1 : -1)
    @list = BrowseController::ListRecord.new(list.id, list.name, list.description, list.points, list.user.username, list_words.count, [], vote)

    @word_data = {}
    list_words.each do |lw|
      word = lw.word
      @word_data[word.id] = {word: word.word, definitions: lw.listword_defs.map {|defi| {id: defi.id, definition: defi.definition} } }
    end
    @word_data = @word_data.sort_by {|k, v| v[:word]}
  end

  def new
    @error_no = 0
    id = params[:id]
    word = params[:word].strip
    word = word.gsub(/[^\w -]/, '')
    add_word(id, word)
 
    redirect_to list_path(id), notice: get_error_message(@error_no)
  end

  def new_multiple
    id = params[:id]
    words = params[:words].split(/\s+/)
    words.each do |word|
      word = word.gsub(/[^\w_-]/, '').gsub(/_/, ' ')
      next if(word.length == 0)
      @error_no = 0
      add_word(id, word)
    end
    
    redirect_to list_path(id)
  end

  def edit_box
    @list_id = params[:id]
    @word_id = params[:wid]

    lw = ListWord.where(list_id: @list_id, word_id: @word_id).first
    @defs = ListwordDef.where(list_word_id: lw.id)

    render layout: false
  end

  def edit
    id = params[:id]
    word_id = params[:wid]

    lw = ListWord.where(:list_id => id, :word_id => word_id).first
    ListwordDef.where(list_word_id: lw.id).destroy_all

    i = 0
    @defs = []
    puts params.to_s
    while params.has_key? "def_#{i}".to_sym
      defi = params["def_#{i}".to_sym].strip
      i += 1
      next if defi.length == 0
      @defs << ListwordDef.create(list_word_id: lw.id, definition: defi)
    end

    render :new_defs, layout: false 
  end

  def delete
    id = params[:id]
    word_id = params[:wid]
    lw = ListWord.where(:list_id => id, :word_id => word_id)
    ListwordDef.where(list_word_id: lw[0].id).destroy_all
    lw.destroy_all

    render nothing: true
  end

  def full_def
    id = params[:id]
    @word = Word.find(id)
    render layout: false
  end

  def favorite
    id = params[:id]
    favorite = Favorite.where(user_id: @logged_uid, list_id: id).first
    Favorite.create(user_id: @logged_uid, list_id: id) if (favorite.nil?)
    render nothing: true
  end

  def unfavorite
    id = params[:id]
    Favorite.where(user_id: @logged_uid, list_id: id).destroy_all
    renirect_to favorites_path
  end
  
  def add_word(list_id, word)
    word_data = Word.where(:word => word).first

    #if word does not exist in database, grab definition from Merriam-Webster
    if(!word_data)
      #data = Nokogiri::XML(File.open('/home/zoonb/memgrid/public/the.xml'))
      data = Nokogiri::XML(open("http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{URI::escape(word)}?key=962712b3-cfd1-41ff-94a7-fa2e38584961"))
      full_def = word_data_to_html(word, data)
      return if(@error_no != 0)

      first_def = first_definition(word, data)
      word_data = Word.create(word: word, first_def: first_def, definition: full_def)
    end

    existing_record = ListWord.where(:list_id => list_id, :word_id => word_data.id).first
    if (existing_record)
      @error_no = 2
      return
    end

    list_word = ListWord.create(list_id: list_id, word_id: word_data.id)
    ListwordDef.create(list_word_id: list_word.id, definition: word_data.first_def)
  end
  
  def word_data_to_html(word, data)
    if data.css('def').length == 0
      return ''
    end

    html = ""
    data.css("entry").each do |entry|
      entry_name = entry.attr('id')
      entry_tok = entry_name.split("[")
      next if entry_tok[0] != word # might give definitions to wrong words

      part_of_speech = entry.at_css('fl')
      part_of_speech = part_of_speech.content if part_of_speech != nil
      if(entry_tok.length > 1)
	html += "<b>#{word}<sup>#{entry_tok[1].chomp(']')}</sup></b> "
      else
	html += "<b>#{word}</b> "
      end
      html += part_of_speech if part_of_speech != nil
      html += "<br>"

      if(entry.at_xpath('def') != nil)
	first_br = false
	entry.at_xpath('def').children().each do |child|
	  type = child.name()
    
	  if(type == 'sn')
	    html += "<br>" if first_br
	    html += "<b>#{child.content}</b> "
	    first_br = true
	  elsif(type == 'sd')
	    html += "<i>#{child.content}</i> "
	  elsif(type == 'dt')
	    def_s = child.to_s
	    def_s = def_s.gsub('<vi>', '&lt;').gsub('</vi>', '&gt;').gsub(/<[^>]+?>/, '').gsub(/^ *:|:$/, '')
	    html += def_s + " "
	    first_br = true
	  end
	end
      elsif(entry.at_xpath('cx') != nil)
	html += entry.at_xpath('cx').content
      end
      html += "<br><br>"
      html = html.gsub("\n", '')
      puts html
    end
    html
  end

  def first_definition(word, data)
    str = ''
    data.css("entry").each do |entry|
      entry_name = entry.attr('id')
      entry_tok = entry_name.split("[")
      next if entry_tok[0] != word # might give definitions to wrong words
      
      if(entry.at_xpath('def') != nil)
	str = entry.at_css('def dt').to_s
	break
      end
    end

    if(str == '' && data.at_xpath('//cx[1]') != nil)
      str = data.at_xpath('//cx').to_s
    end
    str = str.gsub(/<vi>.*?<\/vi>/, '').gsub(/<[^>]+?>/, '').gsub(/^ *:|:$/, '').gsub(/ \d$/, '')
    str
  end

  def get_error_message(error_no)
    return "Word not found in dictionary." if error_no == 1
    return "Word already in list." if error_no == 2
    return ""
  end
end

