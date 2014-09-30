class ProductController < ApplicationController
  before_filter :authorize
  before_filter :need_book

  def index
    lang = I18n.locale.to_s
    @products = Product.where(book_id: current_book.id)
    @products = @products.where("lower(display_name) like lower(?)", "%#{params[:search]}%") if (params[:search])
    respond_to do |format|
      format.json do
        render_api_resp(:ok, data: @products.map do |product|
          unit = product.unit
          name = unit.names[lang] || unit.names['en']
          {
            id: product.id,
            display_name: product.display_name,
            unit: {
              id: unit.id,
              full_name: name['full'],
              short_name: name['short'],
              decimals: unit.decimals
            }
          }
        end)
      end
    end
  end

  def create
    @product = Product.new(display_name: params.require(:name))
    @product.book = current_book

    if @product.valid?
      @product.save!
      return render_api_resp :ok
    end

    render_model_errors_api_resp @product
  end

end