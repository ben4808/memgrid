class DefVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :listword_def
end
