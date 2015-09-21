class AddColumnsTransformsToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :new_org_id, :int
    add_column :rooms, :transformed, :boolean, default: false
    rename_column :holders, :organism_id, :room_id
    add_column :holders, :organism_id, :integer

  end
end
