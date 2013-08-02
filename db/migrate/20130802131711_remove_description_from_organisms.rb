class RemoveDescriptionFromOrganisms < ActiveRecord::Migration
  def up
    remove_column :organisms, :description
  end

  def down
    add_column :organisms, :description, :text
  end
end
