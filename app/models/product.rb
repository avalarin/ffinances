class Product < ActiveRecord::Base
  belongs_to :unit
  belongs_to :book

  validates :unit, :book, :display_name, presence: true
end