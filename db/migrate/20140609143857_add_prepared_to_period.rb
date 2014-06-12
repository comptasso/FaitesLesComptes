class AddPreparedToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :prepared, :boolean, default:false
  end
end
