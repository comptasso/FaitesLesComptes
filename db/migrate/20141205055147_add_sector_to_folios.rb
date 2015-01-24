class AddSectorToFolios < ActiveRecord::Migration
  def change
    add_column :folios, :sector_id, :integer
  end
end
