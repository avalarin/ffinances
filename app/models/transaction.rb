class Transaction < ActiveRecord::Base
  belongs_to :book
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_user_id'

  has_and_belongs_to_many :tags
  has_many :operations, inverse_of: :transact, validate: true

  validates :book, :creator, presence: true

  def operations_groupped
    operations.group_by { |op| op.wallet }
              .map { |w, ops| { wallet: w, sums: group_sums(ops) } }
  end

  # TODO Не нужно отправлять book_id в тегах
  def as_json(options = nil)
    super({ 
      only: [ :id, :date, :description, :transaction_type ],
      methods: [ :creator, :operations_groupped ],
      include: [ :tags ]
    }.merge(options || {}))
  end

  private

  def group_sums ops
    in_sums = {}
    out_sums = {}
    ops.each do |op|
      sums = op.sum < 0 ? out_sums : in_sums
      s = sums[op.currency.id]
      if (s) 
        s[:sum] += op.sum
      else
        sums[op.currency.id] = {
          sum: op.sum,
          currency: op.currency
        }
      end
    end
    return in_sums.values + out_sums.values
  end

end