module FamilyFinances
  VERSION = File.read(Rails.root.join("VERSION")).strip
  REVISION = (`git show --pretty=%H`[0..8]).chomp
end

Rails.application.routes.default_url_options[:host] = Settings.host_name