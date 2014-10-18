class BookUser < ActiveRecord::Base
  self.table_name = "books_users"
  # self.primary_key = [:user_id, :book_id]

  belongs_to :user
  belongs_to :book

  validates :user, :book, :role, presence: true
  validates :role, inclusion: { in: %w(admin master readonly) }
end 