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
  require 'json'

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
      @word_data[word.id] = {word: word.word, definitions: def_list_to_html(lw.listword_defs) }
    end
  end

  def new
    id = params[:id]
    word = params[:word].strip
    word = word.gsub(/[^\w -]/, '')
    res = add_word(id, word)
 
    render text: res.to_json
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
    defs = []
    while params.has_key? "def_#{i}".to_sym
      defi = params["def_#{i}".to_sym].strip
      i += 1
      next if defi.length == 0
      defs << ListwordDef.create(list_word_id: lw.id, definition: defi)
    end

    render text: def_list_to_html(defs) 
  end

  def delete
    id = params[:id]
    word_id = params[:wid]
    #Word.find(word_id).destroy
    lw = ListWord.where(:list_id => id, :word_id => word_id)
    ListwordDef.where(list_word_id: lw[0].id).destroy_all
    lw.destroy_all

    render nothing: true
  end

  def full_def
    @list_id = params[:id]
    @word_id = params[:wid]
    @word = Word.find(@word_id)
    #@show_load_link = @logged_in && List.find(@list_id).user_id.to_s == @logged_uid.to_s
    @show_load_link = false # Turns out Vocabulary.com uses WordNet definitions anyway. How about that?
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

  def export
    id = params[:id]
    list = List.find(id)
    list_words = list.list_words.includes(:word, :listword_defs)

    @word_data = {}
    list_words.each do |lw|
      word = lw.word
      @word_data[word.word] = lw.listword_defs.map {|d| d.definition}
    end
    @keys = @word_data.keys.sort

    text = "Word,Definitions\n"
    @keys.each do |k|
      word = k
      defs = @word_data[k].join(' | ')
      text += "\"#{word}\",\"#{defs}\"\n"
    end
  
    respond_to do |format|
      format.csv { render text: text }
    end
  end

  def import
    id = params[:id]
    list = List.find(id)
    list_words = list.list_words.includes(:word, :listword_defs)
    ids_hash = {}
    list_words.each {|lw| ids_hash[lw.word.word] = lw.word.id}

    lines = params[:file].read.split("\n")
    lines.each_with_index do |line, i|
      next if i == 0
      tok = line.split(",")
      word = tok.shift.strip.gsub(/^"|"$/, '')
      defs = tok.join(',').gsub(/^"|"$/, '').split(' | ').map {|d| d.strip}

      if ids_hash.has_key? word
	lw = list_words.where(word_id: ids_hash[word]).first
	lw.listword_defs.destroy_all
	lw.destroy
      end

      word_rec = Word.where(word: word).first
      if !word_rec
	#def_data = get_google_word(word)
	#word_rec = Word.create(word: word, first_def: def_data[:short_defs].join('|'), definition: def_data[:html_def])
	word_rec = Word.create(word: word, first_def: "", definition: "")
      end
      lw = ListWord.create(list_id: id, word_id: word_rec.id)
      defs.each do |d|
	ListwordDef.create(list_word_id: lw.id, definition: d)
      end
    end
    redirect_to list_path(id)
  end

  def load_vocab_defs
    id = params[:id]
    word_id = params[:wid]
    word = Word.find(word_id).word
    data = Nokogiri::HTML(open("https://www.vocabulary.com/dictionary/#{URI::escape(word)}"))
    list_word = ListWord.where(list_id: id, word_id: word_id).first
    list_word.listword_defs.destroy_all
    data.css('h3.definition').each do |node|
      defi = node.children().last.text.strip
      ListwordDef.create(list_word_id: list_word.id, definition: defi)
    end
    render nothing: true
  end

  def def_list_to_html (defs)
    return "<i>No definition found.</i>" if defs.length == 0
    return "<span title='#{defs[0].definition}'>" + defs[0].definition.truncate(100) + "</span>" if defs.length == 1
    
    html = ""
    defs.each_with_index do |defi, i|
      d = defi.definition 
      html += "<span title='#{d}'><b>#{i+1}.</b> " + d.truncate(100) + "</span>"
      html += "<br>" if i < defs.length - 1
    end
    html
  end

  def add_word(list_id, word)
    word.downcase!
    word_data = Word.where(:word => word).first

    #if word does not exist in database, return a definitionless word. They can import from Vocabulary.com if they want.
    if(!word_data)
      # Old Merriam-Webster code
      #data = Nokogiri::XML(File.open('/home/zoonb/memgrid/public/the.xml'))
      #data = Nokogiri::XML(open("http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{URI::escape(word)}?key=962712b3-cfd1-41ff-94a7-fa2e38584961"))
      #full_def = word_data_to_html(word, data)
      #first_def = first_definition(word, data)
      #word_data = Word.create(word: word, first_def: first_def, definition: full_def)

      # Old Google API code
      #def_data = get_google_word(word)
      #word_data = Word.create(word: word, first_def: def_data[:short_defs].join('|'), definition: def_data[:html_def])

      word_data = Word.create(word: word, first_def: "", definition: "")
    end

    existing_record = ListWord.where(:list_id => list_id, :word_id => word_data.id).first
    return nil if (existing_record)

    list_word = ListWord.create(list_id: list_id, word_id: word_data.id)
    lwdefs = []
    word_data.first_def.split('|').each do |defi|
      next if defi.size == 0
      lwdefs << ListwordDef.create(list_word_id: list_word.id, definition: defi)
    end
    return {id: word_data.id, definition: def_list_to_html(lwdefs)}
  end

  def get_google_word(word)
    short_defs = []
    all_defs = []

    data = JSON.parse(open("http://www.google.com/dictionary/json?callback=a&sl=en&tl=en&q=#{URI::escape(word)}").read.sub(/^[^{]*/, '').sub(/[^}]*$/, ''))
    if(data["primaries"])
      data["primaries"].each do |primary|
	next if primary['type'] != 'headword'
	next if (!primary.has_key?('terms') || !primary.has_key?('entries'))

	cur_def = {pos: '', entries: []}

	primary["terms"].each do |term|
	  next if !term.has_key?('labels')
	  term["labels"].each do |label|
	    cur_def[:pos] = label["text"].downcase if label["title"] == "Part-of-speech"
	  end
	end

	next if cur_def[:pos].length == 0

	primary['entries'].each do |entry|
	  next if (entry['type'] != 'meaning' || !entry.has_key?('terms'))
	  defi = {defi: entry['terms'][0]['text'].gsub(/x27/, "'").gsub(/x3c.*?x3e/, ''), examples: []}
	  if entry.has_key?('entries')
	    entry['entries'].each do |e2|
	      next if (e2['type'] != 'example' || !e2.has_key?('terms'))
	      defi[:examples] << e2['terms'][0]['text'].gsub(/x3c.*?x3e/, '').gsub(/x27/, "'")
	    end
	  end
	  cur_def[:entries] << defi
	end

	all_defs << cur_def
      end

      all_defs.each {|defi| short_defs << defi[:entries][0][:defi]}
    end

    if short_defs.length == 0
      vocab_data = get_vocab_com_word(word)
      short_defs = vocab_data[:short_defs]
      all_defs = vocab_data[:all_defs]
    end

    html = "<b>#{word}</b>"
    all_defs.each do |defi|
      html += "<br><i>#{defi[:pos]}</i><br>"
      defi[:entries].each_with_index do |entry, i|
	html += "#{i+1}. #{entry[:defi]}"
	entry[:examples].each do |ex|
	  html += " &lt;<i>#{ex}</i>&gt;"
	end
	html += "<br>"
      end
    end
    
    {short_defs: short_defs, html_def: html}
  end

  def get_vocab_com_word(word)
    short_defs = []
    all_defs = []

    data = Nokogiri::HTML(open("https://www.vocabulary.com/dictionary/#{URI::escape(word)}"))
    data.css('div.group').each do |group|
      cur_def = {pos: '', entries: []}
      group.css('h3.definition').each_with_index do |node, i|
	pos = node.css('a.anchor').first.text.strip
	defi = node.children().last.text.strip
	short_defs << defi if i == 0
	cur_def[:pos] = pos if cur_def[:pos].length == 0
	cur_def[:entries] << {defi: defi, examples: []}
      end
      all_defs << cur_def
    end
    
    {short_defs: short_defs, all_defs: all_defs}
  end

  def def_list_to_html (defs)
    return "<i>No definition found.</i>" if defs.length == 0
    return "<span title='#{defs[0].definition}'>" + defs[0].definition.truncate(100) + "</span>" if defs.length == 1

    html = ""
    defs.each_with_index do |defi, i|
      d = defi.definition
      html += "<span title='#{d}'><b>#{i+1}.</b> " + d.truncate(100) + "</span>"
      html += "<br>" if i < defs.length - 1
    end
    html
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
end

