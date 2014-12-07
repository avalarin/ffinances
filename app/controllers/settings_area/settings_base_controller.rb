module SettingsArea
  class SettingsBaseController < ApplicationController
    layout "settings"

    before_filter { authorize }
  end
end