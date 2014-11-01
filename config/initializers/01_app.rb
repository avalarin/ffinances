module FamilyFinances
  VERSION = File.read(Rails.root.join("VERSION")).strip
  REVISION = (`git show --pretty=%H`[0..8]).chomp
end