module Books
  class MainController < BookBaseController
    before_filter :authorize
    before_filter only: [ :add_user, :update_user  ] { need_book :admin }

    def index
      @books = current_user.books.order :display_name
      respond_to do |f|
        f.html do
          render 'index', layout: 'application'
        end
        f.json do
          render_api_resp :ok, data: @books
        end
      end
    end

    def details
      @book = current_book
      @admin = has_book_role :admin
      respond_to do |f|
        f.html do
          return render_not_found unless @book
        end
        f.json do
          return render_api_resp :not_found unless @book
          render_api_resp :ok, data: @book
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
      render 'new', layout: 'application'
    end

    def create
      book = params.require(:book)
      book = Book.new(book.permit(:display_name))
      book.owner = current_user

      params.require(:currencies).each do |code|
        currency = Currency.find_by_code(code)
        book.currencies.push(currency) if (currency)
      end

      if (book.valid?)
        book.save!
        return redirect_to books_index_path
      end

      @book = book
      render 'new', layout: 'application'
    end

    def update
      @book = current_book
      return render_not_found unless @book
      @book.update(params.require(:book).permit(:display_name))
      @book.save! if @book.valid?
      render 'details'
    end

    def no_books
      render 'no_books', layout: 'application'
    end

  end
end