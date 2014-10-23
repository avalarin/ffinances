class CreateUpdateWalletBalanceTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER update_wallet_balance AFTER INSERT OR UPDATE OR DELETE ON operations
        FOR EACH ROW EXECUTE PROCEDURE update_wallet_balance_trig();
    SQL
  end

  def down
    execute 'DROP TRIGGER update_wallet_balance ON operations;'
  end
end
