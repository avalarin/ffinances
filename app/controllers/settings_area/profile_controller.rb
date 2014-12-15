require 'RMagick'

module SettingsArea
  class ProfileController < SettingsBaseController

    def index
      @user = current_user
    end

    def update
      @user = current_user
      data = params.require(:user).permit([:display_name, :email])
      email_changed = data[:email] != @user.email
      @user.display_name = data[:display_name]
      @user.email = data[:email]
      if @user.valid?
        if email_changed
          @user.confirmed = false
          @user.confirmation_code = SecureRandom.hex(12)
        end
        @user.save
        UserMailer.email_confirmation(@user).deliver if email_changed
      end
      reload_session
      render 'index'
    end

    def update_avatar
      coords = params[:coords]
      ilist = Magick::ImageList.new
      ilist.from_blob(params[:avatar].read)
      ilist.crop!(Integer(coords[:x]), Integer(coords[:y]), Integer(coords[:w]), Integer(coords[:h]))
      file = Tempfile.new(['avatar', '.jpg'])
      ilist.write(file.path)
      current_user.avatar = file
      current_user.save!
      render_api_resp :ok, data: { avatar: current_user.avatar.url }
    end

    def send_confirmation_email
      user = current_user
      return render_not_found unless user
      if (!user.confirmed)
        UserMailer.email_confirmation(user).deliver
        render_api_resp :ok
      else
        render_api_resp :bad_request, message: 'already_confirmed'
      end
    end

  end
end