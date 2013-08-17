class AddBridgeIdToWritings < ActiveRecord::Migration
  def change
    add_column :writings, :bridge_id, :integer
  end
end
