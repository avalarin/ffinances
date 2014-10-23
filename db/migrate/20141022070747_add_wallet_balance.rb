class AddWalletBalance < ActiveRecord::Migration
  def change
    add_column :wallets, :balance, :decimal
  end
end
