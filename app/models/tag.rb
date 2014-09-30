class Tag < ActiveRecord::Base
  belongs_to :book

  validates :book, :text, presence: true

  def as_json(options = nil)
    super({ only: [:id, :text ] }.merge(options || {}))
  end

end