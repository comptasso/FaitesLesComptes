class AddContinousIdToWritings < ActiveRecord::Migration
  def change
    add_column :writings, :continuous_id, :integer
    add_index :writings, :continuous_id, unique:true
  end
end
