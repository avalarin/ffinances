class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :book_id
      t.string :text
    end
    add_index :tags, :text, :unique => false
  end
end
