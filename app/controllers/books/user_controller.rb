module Books
  class UserController < BookBaseController
    def index
      @book = current_book
      return render_api_resp :not_found unless @book
      @users = @book.users
      respond_to do |f|
        f.html do
          @admin = has_book_role :admin
          render 'index'
        end
        f.json do
          render_api_resp :ok, data: (@users.map do |u|
            { name: u.name, email: u.email, display_name: u.display_name, avatar_url: u.avatar_url,
              book_role: u.book_role, localized_book_role: t(".book_role_#{ u.book_role }")
            }
          end)
        end
      end
    end

    def create
      @book = current_book
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

    def update
      @book = current_book
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
  end
end