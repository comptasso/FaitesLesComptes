class AddUsedToDestination < ActiveRecord::Migration
  def change
    add_column :destinations, :used, :boolean, default:true
  end
end
