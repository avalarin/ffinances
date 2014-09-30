class AddSessionIpUserAgent < ActiveRecord::Migration
  def change
    add_column :sessions, :ip, :string
    add_column :sessions, :user_agent, :string
  end
end
