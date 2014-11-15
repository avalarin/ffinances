class Session < ActiveRecord::Base
  belongs_to :user
  default_scope { joins(:user).includes(:user) }
  validates :user, :key, presence: true
end