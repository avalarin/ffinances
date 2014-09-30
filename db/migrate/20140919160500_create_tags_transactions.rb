class CreateTagsTransactions < ActiveRecord::Migration
  def change
    create_table :tags_transactions do |t|
      t.integer :transaction_id
      t.integer :tag_id
    end
  end
end
