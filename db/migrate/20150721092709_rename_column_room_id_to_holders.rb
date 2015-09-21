class RenameColumnRoomIdToHolders < ActiveRecord::Migration
  def change
    rename_column :holders, :room_id, :organism_id
  end
end
