class AddDefaultValueForWalletBalance < ActiveRecord::Migration
  def up
    change_column :wallets, :balance, :decimal, :default => 0.00
  end

  def down
    change_column :wallets, :balance, :decimal, :default => nil
  end
end
