class AddColumnToTableLines < ActiveRecord::Migration
  def change
    add_column :books, :type, :string
  end
end
