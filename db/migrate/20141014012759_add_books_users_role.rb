class AddBooksUsersRole < ActiveRecord::Migration
  def change
    add_column :books_users, :role, :string
  end
end
