class ListWord < ActiveRecord::Base
  belongs_to :list
  belongs_to :word
  has_many :listword_defs
end
