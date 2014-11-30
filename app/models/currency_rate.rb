class CurrencyRate < ActiveRecord::Base
  belongs_to :base, class_name: 'Currency', foreign_key: 'base_currency_id'
  belongs_to :target, class_name: 'Currency', foreign_key: 'target_currency_id'

  validates :base, :target, presence: true
  validates :value, numericality: { only_integer: false, greater_than: 0 }

  def get(base, target)
    where(base: base, target: target).first
  end
end