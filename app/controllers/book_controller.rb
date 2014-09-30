class BookController < ApplicationController
  before_filter :authorize
  # before_filter :need_book, only: :current

  def index
    @books = current_user.books.order :display_name
  end

  def details
    @book = Book.find_by_key(params.require(:key))
    respond_to do |f|
      f.html do
        return render_not_found unless @book
      end
      f.json do
        return render_api_resp :not_found unless @book
        render_api_resp :ok, data: current_book
      end
    end  
  end

  def current
    @book = current_book
    respond_to do |f|
      f.html do
        need_book 
        render 'details'
      end
      f.json do
        return render_api_resp :ok, message: 'book_not_selected' unless current_book
        render_api_resp :ok, data: current_book
      end
    end    
  end

  def choose
    book = Book.find_by_key(params.require(:key))
    return render_api_resp :not_found unless book
    set_current_book(book)
    return render_api_resp :ok
  end

  def new
    @book = Book.new
  end

  def create
    book = params.require(:book)
    book = Book.new(book.permit(:display_name))
    book.owner = current_user

    params.require(:currencies).each do |code|
      currency = Currency.find_by_code(code)
      book.currencies.push(currency) if (currency) 
    end

    begin
      book.key = SecureRandom.hex(6)
    end while (Book.find_by_key book.key)

    if (book.valid?)
      book.save!
      return redirect_to books_index_path
    end

    @book = book
    render 'new'
  end
  
  def update
    @book = Book.find_by_key(params.require(:key))
    return render_not_found unless @book
    @book.update(params.require(:book).permit(:display_name))
    @book.save! if @book.valid?
    render 'details'
  end

end