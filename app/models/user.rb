class User < ActiveRecord::Base
  before_save { 
    self.email = email.downcase 
    self.name = name.downcase
  }

  has_attached_file :avatar, default_url: ActionController::Base.helpers.asset_path('missing_avatar.png'), styles: { 
    large: '256x256>', 
    middle: '128x128>', 
    small: '24x24>' 
  }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/]

  validates :name, :email, :display_name, presence: true
  validates :name, :email, uniqueness: { case_sensitive: true }
  validates :email, email_format: { message: "doesn't look like an email address" }

  has_secure_password
  validates :password, :presence =>true, :confirmation => true, :length => { :within => 5..40 }, :on => :create
  validates :password, :confirmation => true, :length => { :within => 5..40 }, :on => :update, :unless => lambda{ |user| user.password.blank? }

  def roles= roles
    write_attribute(:roles, roles.join(';'))
  end

  def roles
    roles_str = read_attribute(:roles)
    roles_str ? roles_str.split(';') : []
  end

  def is_admin?
    has_role? :admin
  end

  def has_role? role
    roles.include? role.to_s
  end

  def books
    Book.joins('left outer join books_users on books_users.book_id = books.id')
        .where('books.owner_user_id = ? or books_users.user_id = ?', id, id)
  end

  def avatar_url
    avatar.url
  end

  def as_json(options = nil)
    super({ 
      only: [:name, :email, :display_name ],
      methods: [ :avatar_url ]
    }.merge(options || {}))
  end

end