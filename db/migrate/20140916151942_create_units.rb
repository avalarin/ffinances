class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.json :names
      t.integer :decimals
    end
  end
end
