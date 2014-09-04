class Hub < ActiveRecord::Base
  validates :name, :address, :radio_address, presence: true
  validates :address, uniqueness: true

  has_many :devices

end