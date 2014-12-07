module SettingsArea
  class SecurityController < SettingsBaseController

    def index
      @user = current_user
    end

    def update
      p = params.require(:user).permit([ :old_password, :password, :password_confirmation ])
      @user = current_user
      if @user.authenticate(p[:old_password])
        @user.password = p[:password]
        @user.password_confirmation = p[:password_confirmation]
        if @user.valid?
          @user.save!
          flash.now.notice = t('.password_changed')
        end
      else
        @user.errors.add(:old_password, t('errors.messages.invalid_password'))
      end
      render 'index'
    end

  end
end