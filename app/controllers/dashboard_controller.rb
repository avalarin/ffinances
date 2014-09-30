class DashboardController < ApplicationController
  before_filter :authorize
  before_filter :need_book

  def index
    @book = current_book
  end

end