class AddColumnLockedToCashControls < ActiveRecord::Migration
  def change
    add_column :cash_controls, :locked, :boolean ,default: false 
  end
end
