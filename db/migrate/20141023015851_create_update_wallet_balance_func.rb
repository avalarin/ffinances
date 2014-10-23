class CreateUpdateWalletBalanceFunc < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_wallet_balance(wallet_id INT) 
        RETURNS VOID 
      AS 
      $BODY$
        BEGIN
          UPDATE wallets
            SET balance = (SELECT SUM(sum * currency_rate) FROM operations WHERE operations.wallet_id = wallets.id)
            WHERE wallet_id IS NULL OR wallets.id = wallet_id;
        END;
      $BODY$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute 'DROP FUNCTION update_wallet_balance(wallet_id INT);'
  end
end
