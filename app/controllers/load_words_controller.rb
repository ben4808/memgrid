class LoadWordsController < ApplicationController
  def index
    Word.destroy_all
    File.open('/home/zoonb/Desktop/word_dump', 'r') do |file|
      file.each_line do |line|
	tok = line.split('|')
	Word.create(word: tok[0], first_def: tok[1], definition: tok[2])
      end
    end
    render nothing: true
  end
end
