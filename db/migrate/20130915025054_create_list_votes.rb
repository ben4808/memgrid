class CreateListVotes < ActiveRecord::Migration
  def change
    create_table :list_votes do |t|
      t.belongs_to :user
      t.belongs_to :list
      t.boolean :is_up
    end
  end
end
