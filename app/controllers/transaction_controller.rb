class TransactionController < ApplicationController
  before_filter :authorize
  before_filter only: [ :index, :details ] { need_book :readonly }
  before_filter only: [ :new, :create, :delete  ] { need_book :master }

  def index
    @transactions = Transaction.where(book_id: current_book.id).order(date: :desc)
    @transactions = @transactions.limit(params[:limit]) if params[:limit]
    respond_to do |format|
      format.json do
        render_api_resp :ok, data: @transactions
      end
    end
  end

  def details
    @lang = params[:lang] || I18n.locale.to_s
    @transaction = Transaction.where(book_id: current_book.id, id: params.require(:id)).first
    respond_to do |format|
      format.json do
        return render_api_resp :not_found unless @transaction
        render_api_resp :ok, data: @transaction.to_json_with_operations(@lang)
      end
    end
  end

  def new
    if params[:mode]
      if %w(income outcome transfer other).include? params[:mode]
        @mode = params[:mode]
      else
        render_not_found
      end
    else
      @mode = 'income'
    end

    @transaction = Transaction.new
    @wallets = Wallet.all
    @currencies = Currency.all
  end

  def create
    permitted = get_raw_transaction_from_params
    t = Transaction.new({
      book: current_book,
      creator: current_user,
      transaction_type: permitted[:type],
      date: permitted[:date],
      description: permitted[:description],
      tags: get_tags(permitted[:tags])
    })
    put_new_operations(t, permitted[:operations])

    if t.valid?
      t.save
      return render_api_resp :ok
    end
    return render_api_resp :bad_request, data: { model: {
        operations: t.operations
      }, valid: t.valid?, errors: t.errors }
    render_model_errors_api_resp t
  end

  def edit
    @transaction = Transaction.where(book_id: current_book.id, id: params.require(:id)).first
    return render_not_found unless @transaction
    @mode = @transaction.transaction_type
    @wallets = Wallet.all
    @currencies = Currency.all
  end

  def update
    permitted = get_raw_transaction_from_params
    @transaction = Transaction.where(book_id: current_book.id, id: permitted[:id]).first
    return render_not_found unless @transaction

    # Неудачное именование. Встроенный метод transaction создает транзакцию уровня БД.
    @transaction.transaction do
      @transaction.date = permitted[:date]
      @transaction.description = permitted[:description]
      @transaction.tags = get_tags(permitted[:tags])

      # Удаление операций
      if permitted[:deletedOperations]
        begin
          @deletedOperations = permitted[:deletedOperations]
                                .map { |id| @transaction.operations.find(id) }
                                .each { |op| op.delete }
        rescue ActiveRecord::RecordNotFound
          return render_api_resp :bad_request, message: 'deletion_operation_not_found'
        end
      end

      permitted[:operations].each do |op|
        op_model = op[:id] ? @transaction.operations.find(op[:id]) : nil
        if (op_model)
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
          op_model.transact = @transaction
          @transaction.operations.push(op_model)
        end
      end

      if @transaction.valid?
        @transaction.save
        return render_api_resp :ok
      end
      return render_api_resp :bad_request, data: { model: {
          operations: @transaction.operations
        }, valid: @transaction.valid?, errors: @transaction.errors }
      render_model_errors_api_resp @transaction
    end
  end

  def delete
    @transaction = Transaction.where(book_id: current_book.id, id: params.require(:id)).first
    return render_not_found unless @transaction
    return render_access_denied if ((current_user.id != @transaction.creator.id) && !has_book_role(:admin))
    @transaction.transaction do
      @transaction.operations.delete_all
      @transaction.delete
    end
    respond_to do |format|
      format.json do
        render_api_resp :ok
      end
    end
  end

  private

  def get_raw_transaction_from_params
    params.require('transaction')
          .permit(:id, :description, :date, :type,
                  tags: [],
                  deletedOperations: [],
                  operations: [ :id, :wallet, :currency, :currency_rate, :count, :amount, :unit, :sum, product: [ :id, :display_name ] ])
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
      if !product
        product = Product.new(book: current_book, unit: unit, display_name: raw_product[:display_name])
        product.save
      end
    end
    return [product, unit]
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