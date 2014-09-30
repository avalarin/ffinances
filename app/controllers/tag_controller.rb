class TagController < ApplicationController
  before_filter :authorize
  before_filter :need_book

  def index
    @tags = Tag.where(book_id: current_book.id)
    @tags = @tags.where("text like ?", "%#{params[:search]}%")  if (params[:search])
    respond_to do |format|
      format.json do
        render_api_resp :ok, data: @tags
      end
    end
  end

  def create
    @tag = Tag.new(text: params.require(:text))
    @tag.book = current_book

    if @tag.valid?
      @tag.save!
      return render_api_resp :ok, data: @tag
    end

    render_model_errors_api_resp @tag
  end

end