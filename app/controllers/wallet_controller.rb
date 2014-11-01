class WalletController < ApplicationController
  before_filter :authorize
  before_filter only: [ :index ] { need_book :readonly }
  before_filter only: [ :new, :create  ] { need_book :admin }

  def index
    respond_to do |format|
      format.json do
        render_api_resp :ok, data: (current_book.wallets.order(:display_name).map do |wallet|
          {
            key: wallet.key,
            balance: wallet.balance,
            display_name: wallet.display_name,
            currency: wallet.currency,
            image_url: wallet.type.image_url
          }
        end)
      end
    end
  end

  def new
    @wallet = Wallet.new
    @currencies = Currency.all.order(:name)
    @types = WalletType.all.order(:display_name)
  end

  def create
    @wallet = Wallet.new(params.require(:wallet).permit(:display_name, :currency_id, :type_id, :description))
    @wallet.book = current_book
    @wallet.owner = current_user
    if (@wallet.valid?)
      @wallet.save!
      return redirect_to dashboard_path
    end
    render 'new'
  end

end