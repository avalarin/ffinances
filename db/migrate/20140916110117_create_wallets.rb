class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string :key
      t.string :display_name
      t.integer :book_id
      t.integer :owner_user_id
      t.integer :currency_id
      t.string :type_id
      t.string :description
      t.timestamps
    end
    add_index :wallets, :key, :unique => true
  end
end
