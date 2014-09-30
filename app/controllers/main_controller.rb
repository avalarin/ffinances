class MainController < ApplicationController
  before_filter :authorize

  def index
    redirect_to dashboard_path
  end

end