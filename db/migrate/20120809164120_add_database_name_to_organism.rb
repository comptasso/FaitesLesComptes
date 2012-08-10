class AddDatabaseNameToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :database_name, :string

  end
end
