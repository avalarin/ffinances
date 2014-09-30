class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :display_name
      t.attachment :avatar

      t.boolean :approved, default: false
      t.boolean :locked, default: false

      t.string :roles
      t.datetime :last_login_at
      t.string :password_digest

      t.timestamps
    end
  end
end
