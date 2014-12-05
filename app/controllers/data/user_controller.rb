class Data::UserController < ApplicationController

  def index
    @users = User.all
    if (params[:search])
      s = "%#{ params[:search].mb_chars.downcase.to_s }%"
      @users = @users.where("lower(name) like ? or lower(email) like ? or lower(display_name) like ?", s, s, s)
    end
    respond_to do |format|
      format.json do
        render_api_resp :ok, data: @users.order(:name)
      end
    end
  end

end