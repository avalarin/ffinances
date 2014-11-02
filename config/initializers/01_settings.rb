class Settings < Settingslogic
    source "#{Rails.root}/config/settings.yml"
    namespace Rails.env

    Settings[:app_name] ||= 'FFinances'
    Settings[:host_name] ||= 'localhost'

    Settings[:security] ||= {}
    Settings.security[:persistent_session_lifetime] = 30.days
    Settings.security[:session_lifetime] = 30.minutes
    Settings.security[:registration_mode] = Settings.security[:registration_mode] ?
      Settings.security[:registration_mode].to_sym : :free

    unless [:free, :invites, :disabled].include? Settings.security[:registration_mode]
        raise "Unknown registration mode " + Settings.security[:registration_mode].to_s
    end

    Settings[:mail] ||= Settingslogic.new({})
    Settings.mail[:from] ||= 'ffinances@localhost'
    Settings.mail[:smtp] ||= Settingslogic.new({})
    Settings.mail.smtp[:server] ||= 'localhost'
    Settings.mail.smtp[:port] ||= 25
    Settings.mail.smtp[:user_name] ||= 'user'
    Settings.mail.smtp[:password] ||= 'password'

    Settings[:admin] ||= Settingslogic.new({})
    Settings.admin[:page_size] ||= 12
end