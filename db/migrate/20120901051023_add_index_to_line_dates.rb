class AddIndexToLineDates < ActiveRecord::Migration
  def change
    add_index :lines, :line_date
  end
end
