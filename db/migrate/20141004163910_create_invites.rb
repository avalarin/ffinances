class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :code
      t.string :email
      t.integer :user_id
      t.boolean :activated
      t.datetime :activated_at
      t.timestamps
    end
  end
end
