class Word < ActiveRecord::Base
  has_many :list_words
  has_many :lists, through: :list_words
end
