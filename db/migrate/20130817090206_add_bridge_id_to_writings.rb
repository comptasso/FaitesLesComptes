class AddBridgeIdToWritings < ActiveRecord::Migration
  def change
    add_column :writings, :bridge_id, :integer
    add_column :writings, :bridge_type, :string
  end
end
