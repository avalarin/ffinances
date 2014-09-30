class Unit < ActiveRecord::Base
  validates :names, presence: true
  validates :decimals, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end