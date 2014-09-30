class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionHelper
  include RenderHelper
  include SecurityHelper
  include UserProfileHelper

  helper BootstrapHelpers::Helpers

  def authorize role = nil
    if (!authenticated? || (role && !current_user.has_role?(role)))
      if request.xhr?
        render_api_resp :unauthorized, data: {
          login_page: login_path
        }
      else
        redirect_to login_path(r: request.fullpath)
      end
      false
    end
  end
  
  def need_book
    book = current_book
    if (!book)
      if (current_user.books.size > 0)
        redirect_to books_index_path
      else
        redirect_to new_book_path
      end
      return false
    end
    true
  end

end
