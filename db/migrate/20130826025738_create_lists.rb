class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.belongs_to :user
      t.string :name
      t.integer :points
      t.text :description
      t.boolean :public
    end
  end
end
