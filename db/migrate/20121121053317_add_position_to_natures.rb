class AddPositionToNatures < ActiveRecord::Migration
  def change
    add_column :natures, :position, :integer

  end
end
