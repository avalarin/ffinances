class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :key
      t.string :display_name
      t.integer :owner_user_id
      t.timestamps
    end
    add_index :books, :key, :unique => true
  end
end
