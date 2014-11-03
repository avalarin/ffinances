module FamilyFinances
  VERSION = File.read(Rails.root.join("VERSION")).strip

  if File.exist? Rails.root.join("REVISION")
    REVISION = File.read(Rails.root.join("REVISION")).strip
  else
    REVISION = (`git show --pretty=%H`[0..8]).chomp
  end
end

Rails.application.routes.default_url_options[:host] = Settings.host_name