class TransactionController < ApplicationController
  before_filter :authorize
  before_filter only: [ :index ] { need_book :readonly }
  before_filter only: [ :new, :create  ] { need_book :master }

  def index
    respond_to do |format|
      format.json do
        render_api_resp :ok, data: Transaction.all.order(date: :desc)
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
    permitted = params.require('transaction')
                      .permit(:description, :date, :type,
                              tags: [], 
                              operations: [ :wallet, :currency, :currency_rate, :count, :amount, :unit, :sum, product: [ :id, :display_name ] ])
    tags = permitted[:tags] ? permitted[:tags].map { |id| Tag.where(id: id, book_id: current_book.id).first } : []
    t = Transaction.new({
      book: current_book,
      creator: current_user,
      transaction_type: permitted[:type],
      date: permitted[:date],
      description: permitted[:description],
      tags: tags
    })

    permitted[:operations].each do |op|   
      if op[:product]
        unit = Unit.find(op[:unit])
        if op[:product][:id]
          product_model = Product.where(book_id: current_book.id, id: op[:product][:id]).first
        end
        if !product_model && op[:product][:display_name]
          product_model = Product.where(book_id: current_book.id, display_name: op[:product][:display_name]).first
        end
        if !product_model
          product_model = Product.new(book: current_book, unit: unit, display_name: op[:product][:display_name])
          product_model.save
        end
      else
        unit = nil
        product_model = nil
      end

      op_model = Operation.new({
        transact: t,
        wallet: Wallet.where(key: op[:wallet], book_id: current_book.id).first,
        currency: Currency.find_by_code(op[:currency]),
        product: product_model,
        unit: unit,
        currency_rate: op[:currency_rate],
        count: op[:count],
        amount: op[:amount],
        sum: op[:sum]
      })
      t.operations.push(op_model)
    end
    if t.valid?
      t.save
      return render_api_resp :ok
    end
    return render_api_resp :bad_request, data: { model: {
        operations: t.operations
      }, valid: t.valid?, errors: t.errors }
    render_model_errors_api_resp t
  end

end