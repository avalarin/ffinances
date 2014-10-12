class Invite < ActiveRecord::Base
  validates :code, presence: true
  validates :code, uniqueness: { case_sensitive: true }

  belongs_to :user

  def self.filters
    [:all, :free, :activated]
  end

  def self.filter f
    case f
      when :all
        all
      when :free
        where activated: false
      when :activated
        where activated: true
      else
        []
      end
  end

end