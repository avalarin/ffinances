module SettingsArea
  class MainController < SettingsBaseController
    def index
      redirect_to settings_profile_path
    end
  end
end