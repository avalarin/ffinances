class Operation < ActiveRecord::Base
  belongs_to :transact, inverse_of: :operations, class_name: "Transaction", foreign_key: 'transaction_id'
  belongs_to :wallet
  belongs_to :currency
  belongs_to :unit
  belongs_to :product

  validates :transact, :wallet, :currency, presence: true
  validates :count, numericality: { only_integer: false, greater_than: 0 }

  def as_json(options = nil)
    super({ 
        only: [ :count, :amount, :sum ] 
      }.merge(options || {}))
  end


end