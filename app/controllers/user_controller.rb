class UserController < ApplicationController
  before_filter :authorize

  def profile
    @user = User.find_by(name: params.require(:name))
    return render_not_found unless @user
  end

end