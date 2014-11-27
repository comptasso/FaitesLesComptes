class AddSectorIdToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :sector_id, :integer
  end
end
