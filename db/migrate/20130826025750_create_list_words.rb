class CreateListWords < ActiveRecord::Migration
  def change
    create_table :list_words do |t|
      t.belongs_to :list
      t.belongs_to :word
    end
  end
end
