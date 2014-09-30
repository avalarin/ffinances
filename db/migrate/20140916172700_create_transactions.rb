class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :book_id
      t.integer :creator_user_id
      t.string :description
      t.string :transaction_type
      t.datetime :date
      t.timestamps
    end
  end
end
