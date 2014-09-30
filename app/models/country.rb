class Country < ActiveRecord::Base
  validates :code, :name, presence: true

  has_and_belongs_to_many :currencies
end