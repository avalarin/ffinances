module Transactions
  class BaseService < BookBaseService

    private

    def get_raw_transaction
      params.require('transaction')
      .permit(:id, :description, :date, :type,
              tags: [],
              deletedOperations: [],
              operations: [ :id, :wallet, :currency, :currency_rate, :count,
                            :amount, :unit, :sum, product: [ :id, :display_name ]
              ])
    end

    def get_tags(raw)
      raw ? raw.map { |id| Tag.where(id: id, book_id: current_book.id).first } : []
    end

    def get_product_and_unit(raw_product, unit_id)
      product, unit = [nil, nil]
      if raw_product
        unit = Unit.find(unit_id)
        if raw_product[:id]
          product = Product.where(book_id: current_book.id, id: raw_product[:id]).first
        end
        if !product && raw_product[:display_name]
          product = Product.where(book_id: current_book.id, display_name: raw_product[:display_name]).first
        end
        unless product
          product = Product.new(book: current_book, unit: unit, display_name: raw_product[:display_name])
          product.save
        end
      end
      [product, unit]
    end

    def put_new_operations(transaction, raw)
      raw.each do |op|
        op_model = create_operation(op)
        op_model.transact = transaction
        transaction.operations.push(op_model)
      end
    end

    def create_operation(raw)
      product, unit = get_product_and_unit(raw[:product], raw[:unit])
      Operation.new({
          wallet: Wallet.where(key: raw[:wallet], book_id: current_book.id).first,
          currency: Currency.find_by_code(raw[:currency]),
          product: product,
          unit: unit,
          currency_rate: raw[:currency_rate],
          count: raw[:count],
          amount: raw[:amount],
          sum: raw[:sum]
      })
    end

  end
end