class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :book_id
      t.integer :unit_id
      t.string :display_name
    end
  end
end
