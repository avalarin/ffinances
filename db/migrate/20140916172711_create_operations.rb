class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.integer :transaction_id
      t.integer :wallet_id
      t.integer :currency_id
      t.decimal :currency_rate

      t.integer :product_id
      t.integer :unit_id
      t.decimal :count
      t.decimal :amount
      t.decimal :sum
    end
  end
end
