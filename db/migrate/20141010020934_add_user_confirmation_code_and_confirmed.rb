class AddUserConfirmationCodeAndConfirmed < ActiveRecord::Migration
  def change
    remove_column :users, :approved
    add_column :users, :confirmation_code, :string
    add_column :users, :confirmed, :boolean
  end
end
