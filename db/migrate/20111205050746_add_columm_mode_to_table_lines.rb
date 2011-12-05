class AddColummModeToTableLines < ActiveRecord::Migration
  def change
    add_column :lines, :payment_mode, :string
  end
end
