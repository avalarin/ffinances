class Book < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'
  has_and_belongs_to_many :users
  has_and_belongs_to_many :currencies

  has_many :wallets

  validates :key, :display_name, :owner, presence: true
end