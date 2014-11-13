class PublicController < ApplicationController

  def index
    if authenticated?
      redirect_to dashboard_path
    else
      render 'landing'
    end
  end

end