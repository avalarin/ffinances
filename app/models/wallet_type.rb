class WalletType < ActiveRecord::Base
  validates :display_name, :image_name, presence: true

  def image_url
    ActionController::Base.helpers.image_path('wallet/' + image_name) 
  end

end