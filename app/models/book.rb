class Book < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'
  has_and_belongs_to_many :users
  has_and_belongs_to_many :currencies

  has_many :wallets
  has_many :transactions

  default_scope { joins(:owner).includes(:owner) }

  validates :key, :display_name, :owner, presence: true

  after_initialize do |book|
    unless book.key
      begin
        book.key = SecureRandom.hex(6)
      end while (Book.find_by_key book.key)
    end
  end

  def users
    User.select("users.*, (case when (users.id = #{owner.id}) then \'owner\' else books_users.role end) as book_role")
        .joins('left outer join books_users on books_users.user_id = users.id')
        .where('books_users.book_id = ? or users.id = ?', id, owner.id)
  end

  def top_currencies
    transactions.joins(:operations)
      .group('operations.currency_id')
      .order('count(*) desc')
      .pluck('operations.currency_id')
  end

  def get_role user
    return :owner if owner.id == user.id
    book_user = BookUser.where(book_id: id, user_id: user.id).first
    return :none unless book_user
    return book_user.role.to_sym
  end

  def as_json(options = nil)
    super({
      only: [:key, :display_name, :created_at, :updated_at ],
      methods: [ :owner ]
    }.merge(options || {}))
  end
end