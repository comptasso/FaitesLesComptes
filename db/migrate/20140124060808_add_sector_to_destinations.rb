class AddSectorToDestinations < ActiveRecord::Migration
  def change
    add_column :destinations, :sector_id, :integer
    add_column :bank_accounts, :sector_id, :integer
    add_column :cashes, :sector_id, :integer  
  end
end
