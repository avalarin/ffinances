module Transactions
  class UpdateService < BaseService

    def execute
      raw = get_raw_transaction
      transaction = Transaction.where(book_id: current_book.id, id: raw[:id]).first
      raise ActiveRecord::RecordNotFound, 'transaction not found' unless transaction

      transaction.date = raw[:date]
      transaction.description = raw[:description]
      transaction.tags = get_tags(raw[:tags])

      return transaction unless transaction.valid?

      # Неудачное именование. Встроенный метод transaction создает транзакцию уровня БД.
      transaction.transaction do
        # Удаление операций
        if raw[:deletedOperations]
          raw[:deletedOperations]
            .map { |id| transaction.operations.find(id) }
            .each { |op| op.delete }
        end
        # Добавление и обновление операций
        raw[:operations].each do |op|
          op_model = op[:id] ? transaction.operations.find(op[:id]) : nil
          if op_model
            product, unit = get_product_and_unit(op[:product], op[:unit])
            op_model.wallet = Wallet.where(key: op[:wallet], book_id: current_book.id).first
            op_model.currency = Currency.find_by_code(op[:currency])
            op_model.product = product
            op_model.unit = unit
            op_model.currency_rate = op[:currency_rate]
            op_model.count = op[:count]
            op_model.amount = op[:amount]
            op_model.sum = op[:sum]
          else
            op_model = create_operation(op)
            op_model.transact = transaction
            transaction.operations.push(op_model)
          end
        end

        if transaction.save
          log_action(current_user, :update, transaction, current_book)
        else
          raise ActiveRecord::Rollback
        end
      end

      transaction
    end
  end
end