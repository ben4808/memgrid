class CreateListwordDefs < ActiveRecord::Migration
  def change
    create_table :listword_defs do |t|
      t.belongs_to :list_word
      t.string :definition
    end
  end
end