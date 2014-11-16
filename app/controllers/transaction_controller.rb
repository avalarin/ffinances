class TransactionController < ApplicationController
  before_filter :authorize
  before_filter(only: [ :index, :details ]) { need_book :readonly }
  before_filter(only: [ :new, :create, :delete ]) { need_book :master }

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
    @transaction = current_book.transactions.find(params.require(:id))
    respond_to do |format|
      format.json do
        return render_api_resp :not_found unless @transaction
        render_api_resp :ok, data: @transaction.to_json_with_operations(@lang)
      end
    end
  end

  def new
    @mode = params[:mode] || 'income'
    render_not_found unless %w(income outcome transfer other).include? @mode

    @transaction = Transaction.new
    @wallets = Wallet.all
    @currencies = Currency.all
  end

  def create
    @transaction = Transactions::CreateService.new(current_book, current_user, params).execute
    if @transaction.valid?
      return render_api_resp :ok
    end
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
    @transaction = Transactions::UpdateService.new(current_book, current_user, params).execute
    if @transaction.valid?
      return render_api_resp :ok
    end
    render_model_errors_api_resp @transaction
  end

  def delete
    @transaction = current_book.transactions.find(params.require(:id))
    return render_not_found unless @transaction
    return render_access_denied if ((current_user.id != @transaction.creator.id) && !has_book_role(:admin))
    @transaction.destroy
    respond_to do |format|
      format.json do
        render_api_resp :ok
      end
    end
  end

end