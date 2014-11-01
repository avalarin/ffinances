class Session < ActiveRecord::Base
  belongs_to :user
  validates :user, :key, presence: true
end