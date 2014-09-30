class CreateCurrencyRates < ActiveRecord::Migration
  def change
    create_table :currency_rates do |t|
      t.integer :base_currency_id
      t.integer :target_currency_id
      t.decimal :value
      t.datetime :date
    end
    add_index :currency_rates, [:base_currency_id, :target_currency_id], :unique => true
  end
end
