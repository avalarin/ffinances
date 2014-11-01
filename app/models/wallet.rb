class Wallet < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'
  belongs_to :type,  class_name: 'WalletType', foreign_key: 'type_id'
  belongs_to :currency
  belongs_to :book

  validates :key, :display_name, :owner, :currency, :type, presence: true

  after_initialize do |wallet|
    unless wallet.key
      begin
        wallet.key = SecureRandom.hex(6)
      end while (Wallet.find_by_key wallet.key)
    end
  end


  def image_url
    type.image_url
  end

  def as_json(options = nil)
    super({
      only: [ :key, :display_name, :balance ],
      methods: [ :currency, :image_url ]
    }.merge(options || {}))
  end
end