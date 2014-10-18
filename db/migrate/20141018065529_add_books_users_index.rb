class AddBooksUsersIndex < ActiveRecord::Migration
  def change
    add_index :books_users, [:user_id, :book_id]
    add_column :books_users, :id, :primary_key
  end
end
