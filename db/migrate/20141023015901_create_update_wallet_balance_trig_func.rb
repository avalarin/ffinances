class CreateUpdateWalletBalanceTrigFunc < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_wallet_balance_trig() 
        RETURNS TRIGGER
      AS
      $BODY$    
        BEGIN
          IF (TG_OP = 'INSERT') THEN
              UPDATE wallets 
                SET balance = balance + NEW.sum * NEW.currency_rate
                WHERE wallets.id = NEW.wallet_id;
              RETURN NEW;
          ELSIF (TG_OP = 'UPDATE') THEN
              UPDATE wallets 
                SET balance = balance - OLD.sum * OLD.currency_rate + NEW.sum * NEW.currency_rate
                WHERE wallets.id = NEW.wallet_id;
              RETURN NEW;
          ELSIF (TG_OP = 'DELETE') THEN
            UPDATE wallets 
                SET balance = balance - OLD.sum * OLD.currency_rate
                WHERE wallets.id = OLD.wallet_id;
              RETURN OLD;
          END IF;
          RETURN NULL;
        END;
      $BODY$
      LANGUAGE plpgsql VOLATILE;
    SQL
  end

  def down
    execute 'DROP FUNCTION update_wallet_balance_trig();'
  end
end
