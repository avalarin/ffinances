class Data::UserController < ApplicationController
  
  def index
    @users = User.all
    if (params[:search])
      s = "%#{params[:search]}%"
      @users = @users.where("name like ? or email like ? or display_name like ?", s, s, s)  
    end
    respond_to do |format|
      format.json do
        render_api_resp :ok, data: @users.order(:name)
      end
    end
  end

end