class Currency < ActiveRecord::Base
  validates :code, presence: true
  has_and_belongs_to_many :countries
end