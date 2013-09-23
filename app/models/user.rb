class User < ActiveRecord::Base
  has_many :lists
  has_many :favorites
  has_many :list_votes
  has_many :def_votes
end
