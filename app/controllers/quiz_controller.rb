class QuizController < ApplicationController
  def normal
    id = params[:id]
    @word_data = get_word_data_in_list(id).shuffle
  end

  def reverse
    id = params[:id]
    @word_data = get_word_data_in_list(id).shuffle
  end

  def get_word_data_in_list(id)
    @list = List.find(id)
    list_words = @list.list_words.includes(:word, :listword_defs)

    data = []
    list_words.each do |lw|
      word = lw.word
      defs = lw.listword_defs
      data << {id: word.id, word: word.word, definitions: defs.map {|defi| defi.definition} } if defs.length > 0 && !defs[0].definition.strip.empty?
    end
    data
  end
end
