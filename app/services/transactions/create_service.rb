module Transactions
  class CreateService < Transactions::BaseService

    def execute
      raw = get_raw_transaction
      transaction = Transaction.new({
          book: current_book,
          creator: current_user,
          transaction_type: raw[:type],
          date: raw[:date],
          description: raw[:description],
          tags: get_tags(raw[:tags])
      })
      put_new_operations(transaction, raw[:operations])

      if transaction.save
        log_action(current_user, :create, transaction, current_book)
      end

      transaction
    end

  end
end
