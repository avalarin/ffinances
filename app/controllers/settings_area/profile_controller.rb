require 'RMagick'

module SettingsArea
  class ProfileController < SettingsBaseController

    def index
      @user = current_user
    end

    def update
      @user = current_user
      @user.update(params.require(:user).permit([:display_name, :email]))
      if (@user.valid?)
        @user.save
      end
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

  end
end