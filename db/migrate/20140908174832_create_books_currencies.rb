class CreateBooksCurrencies < ActiveRecord::Migration
  def change
    create_table :books_currencies do |t|
      t.integer :book_id
      t.integer :currency_id
    end
  end
end
