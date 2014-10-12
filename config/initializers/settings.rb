class Settings < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env

    Settings[:app_name] ||= 'FFinances'

    Settings[:security] ||= {}
    Settings.security[:persistent_session_lifetime] = 30.days
    Settings.security[:session_lifetime] = 30.minutes
    Settings.security[:registration_mode] = Settings.security[:registration_mode] ? 
      Settings.security[:registration_mode].to_sym : :free

    unless [:free, :invites, :disabled].include? Settings.security[:registration_mode]
        raise "Unknown registration mode " + Settings.security[:registration_mode].to_s
    end
    

    Settings[:admin] ||= Settingslogic.new({}) 
    Settings.admin[:page_size] ||= 12
end