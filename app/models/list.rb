class List < ActiveRecord::Base
  belongs_to :user
  has_many :list_words
  has_many :words, through: :list_words
end
