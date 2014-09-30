class SessionController < ApplicationController
  
  class Login
    include ActiveModel::Model
    attr_accessor :name, :password, :remember
    validates :name, :password, presence: true
  end

  def new
    if (authenticated?)
        return redirect_to root_path
    end
    @login = Login.new
  end

  def create
    login = params.require(:login).permit(:name, :password, :remember)
    user = User.find_by_name(login[:name])
    if (user)
        if (user.locked)
            flash.now.alert = t('errors.messages.user_locked')
        elsif (!user.approved)
            flash.now.alert = t('errors.messages.account_not_activated')
        elsif (!user.authenticate(login[:password]))
            flash.now.alert = t('errors.messages.invalid_email_or_password')
        else
          client_ip = request.env['REMOTE_ADDR']
          client_user_agent = request.env['HTTP_USER_AGENT']
          login_user user, login[:remember] == "true", ip: client_ip, user_agent: client_user_agent
          return redirect_to(params[:r] || root_path)
        end
    else 
        flash.now.alert = t('errors.messages.invalid_email_or_password')
    end
    @login = Login.new login
    render 'new'
  end

  def destroy
    logout_user
    redirect_to login_path
  end

end