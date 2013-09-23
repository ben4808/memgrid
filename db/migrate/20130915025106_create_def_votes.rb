class CreateDefVotes < ActiveRecord::Migration
  def change
    create_table :def_votes do |t|
      t.belongs_to :user
      t.belongs_to :listword_def
    end
  end
end
