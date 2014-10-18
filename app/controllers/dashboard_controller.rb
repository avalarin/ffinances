class DashboardController < ApplicationController
  before_filter :authorize
  before_filter only: [ :index ] { need_book :readonly }

  def index
    @book = current_book
  end

end