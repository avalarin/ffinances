class Settings < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env

    Settings[:app_name] ||= 'FFinances'

    Settings[:security] ||= {}
    Settings.security[:persistent_session_lifetime] = 30.days
    Settings.security[:session_lifetime] = 30.minutes

end