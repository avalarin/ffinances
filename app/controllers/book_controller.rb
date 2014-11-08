class BookController < ApplicationController
  before_filter :authorize
  before_filter only: [ :add_user, :update_user  ] { need_book :admin }

  def index
    @books = current_user.books.order :display_name
    respond_to do |f|
      f.html do
        render 'index'
      end
      f.json do
        render_api_resp :ok, data: @books
      end
    end
  end

  def details
    @book = Book.find_by_key(params.require(:key))
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

  def users
    @book = Book.find_by_key(params.require(:key))
    return render_api_resp :not_found unless @book
    @users = @book.users
    render_api_resp :ok, data: (@users.map do |u|
      { name: u.name, email: u.email, display_name: u.display_name, avatar_url: u.avatar_url,
        book_role: u.book_role, localized_book_role: t(".book_role_#{ u.book_role }")
      }
    end)
  end

  def add_user
    @book = Book.find_by_key(params.require(:key))
    @user = User.find_by_name(params.require(:user))
    @role = params.require(:role)
    return render_api_resp :not_found, message: 'book_not_found' unless @book
    return render_api_resp :not_found, message: 'user_not_found' unless @user
    @book_user = BookUser.where(book_id: @book.id, user_id: @user.id).first
    return render_api_resp :bad_request, message: 'book_user_already_exists' if @book_user
    @book_user = BookUser.new({ book: @book, user: @user, role: @role })
    if (@book_user.valid?)
      @book_user.save!
      return render_api_resp :ok
    end
    render_model_errors_api_resp @book_user
  end

  def update_user
    @book = Book.find_by_key(params.require(:key))
    @user = User.find_by_name(params.require(:user))
    @role = params.require(:role)
    return render_api_resp :not_found, message: 'book_not_found' unless @book
    return render_api_resp :not_found, message: 'user_not_found' unless @user
    @book_user = BookUser.where(book_id: @book.id, user_id: @user.id).first
    return render_api_resp :not_found, message: 'book_user_not_found' unless @book_user
    if (@role == 'delete')
      @book_user.delete
      return render_api_resp :ok
    end
    @book_user.role = @role
    if (@book_user.valid?)
      @book_user.save!
      return render_api_resp :ok
    end
    render_model_errors_api_resp @book_user
  end

  def no_books
  end

end