class AddColumnStatusToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :status, :string
  end
end
