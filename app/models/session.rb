class Session < ActiveRecord::Base
  belongs_to :user
  validates :user, :ip, :user_agent, :key, presence: true
end