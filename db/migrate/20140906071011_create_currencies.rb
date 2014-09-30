class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :code
      t.string :symbol
      t.string :name
      t.string :global_name
    end
    add_index :currencies, :code, :unique => true
  end
end