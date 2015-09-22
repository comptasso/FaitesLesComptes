class DropTablesLinesAndListings < ActiveRecord::Migration
  def self.table_exists?(name)
    ActiveRecord::Base.connection.tables.include?(name)
  end
  
  def up
    drop_table :lines if table_exists?(:lines)
    drop_table :listings if table_exists?(:listings)
  end
  
  def down 
    Rails.logger.warn 'La migration ne fait rien car les tables lines et listings ne sont plus censées exister'
  end
end
