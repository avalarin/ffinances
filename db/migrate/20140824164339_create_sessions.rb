class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.uuid :key
      t.integer :user_id
      t.boolean :persistent, default: false
      t.boolean :closed, default: false
      t.datetime :closed_at
      t.datetime :expires_at
      t.timestamps
    end
    add_index :sessions, :key, :unique => true
  end
end
