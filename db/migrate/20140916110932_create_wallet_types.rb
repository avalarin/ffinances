class CreateWalletTypes < ActiveRecord::Migration
  def change
    create_table :wallet_types do |t|
      t.string :display_name
      t.string :image_name
    end
  end
end
