class Wallet < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'
  belongs_to :type,  class_name: 'WalletType', foreign_key: 'type_id'
  belongs_to :currency
  belongs_to :book

  validates :key, :display_name, :owner, :currency, :type, presence: true

  def image_url
    type.image_url
  end

  def as_json(options = nil)
    super({ 
      only: [ :key, :display_name ],
      methods: [ :currency, :image_url ]
    }.merge(options || {}))
  end
end