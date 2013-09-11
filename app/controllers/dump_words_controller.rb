class DumpWordsController < ApplicationController
  def index
    @data = []
    Word.all.each do |word|
      @data << [word.word, word.first_def, word.definition].join('|')
    end
  end
end
