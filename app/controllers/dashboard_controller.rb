class DashboardController < ApplicationController
  before_filter :authorize
  before_filter only: [ :index ] { need_book :readonly }

  def index
    @book = current_book
    @is_admin = has_book_role :admin
    @is_master = has_book_role :master
  end

end