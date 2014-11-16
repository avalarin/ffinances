class BookBaseService < BaseService
  attr_accessor :current_book

  def initialize(current_book, current_user, params)
    @current_book = current_book
    super(current_user, params)
  end

end