class ChangeWalletsTypeIdType < ActiveRecord::Migration
  class << self
    include AlterColumn
  end

  def self.up
    alter_column :wallets, :type_id, :integer, 'USING CAST(type_id AS integer)', 0
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end